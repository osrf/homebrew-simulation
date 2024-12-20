class GzTransport14 < Formula
  desc "Transport middleware for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/gz-transport-14.0.0.tar.bz2"
  sha256 "88cbcef69f16ea5124ff41766cc59c0277bfc3ae57c405f3fbae1dbee874a1c0"
  license "Apache-2.0"
  revision 10

  head "https://github.com/gazebosim/gz-transport.git", branch: "gz-transport14"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 sonoma:  "5735eb690cb12ddb870df4d328edb51470ee920388e5245f27403d59ecf913f0"
    sha256 ventura: "7650984bb6456c35f6deca618363a55653b34316161bea9c5876a8133766ee60"
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "pybind11" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]

  depends_on "abseil"
  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "gz-cmake4"
  depends_on "gz-math8"
  depends_on "gz-msgs11"
  depends_on "gz-tools2"
  depends_on "gz-utils3"
  depends_on macos: :mojave # c++17
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "sqlite"
  depends_on "tinyxml2"
  depends_on "zeromq"

  patch do
    # Support building python bindings against external gz-transport library
    # Remove this patch with the next release
    url "https://github.com/gazebosim/gz-transport/commit/250e95f0757af410adfaab213b3077c0a501252e.patch?full_index=1"
    sha256 "b7184cc5a1e505ff31a43eacb5b5aa6ac217a07b4eec81e1585f14db6806abb0"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.13"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/transport14", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # first build without python bindings
    mkdir "build" do
      system "cmake", "..", *cmake_args, "-DSKIP_PYBIND11=ON"
      system "make", "install"
    end

    # now build only the python bindings
    pythons.each do |python|
      # remove @ from formula name
      python_name = python.name.tr("@", "")
      mkdir "build_#{python_name}" do
        system "cmake", "../python", *cmake_args, python_cmake_arg(python)
        system "make", "install"
        (lib/"#{python_name}/site-packages").install Dir[lib/"python/*"]
        rmdir prefix/"lib/python"
      end
    end
  end

  test do
    # test CLI executables
    system libexec/"gz/transport14/gz-transport-service"
    system libexec/"gz/transport14/gz-transport-topic"
    # build against API
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <gz/transport.hh>
      int main() {
        gz::transport::NodeOptions options;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-transport14 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-transport14::gz-transport14)
    EOS
    system "pkg-config", "gz-transport14"
    cflags = `pkg-config --cflags gz-transport14`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-transport14",
                   "-lc++",
                   "-o", "test"
    ENV["GZ_PARTITION"] = rand((1 << 32) - 1).to_s
    system "./test"
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
    # check python import
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.transport14"
    end
  end
end
