class GzTransport15 < Formula
  desc "Transport middleware for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/gz-transport-15.0.0.tar.bz2"
  sha256 "d423ca7bfeee06bcca38311fce0da77f7ef03fb62c97cef74fc0cff2fa266f88"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-transport.git", branch: "gz-transport15"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "f99f42ba3b2ed24def11d45ee7439e6e01706166ad5acbce34575ffad6e00bb6"
    sha256 arm64_sonoma:  "c4e8f829cc45859c240a6861344099fd0358ccec90cf02beb5a75cd6ff8a63e9"
    sha256 sonoma:        "0d8e0d737c76214e0034817961a284c6e48e01344760f5e6fbda89c1648ec1ed"
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "pybind11" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]

  depends_on "abseil"
  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "gz-cmake5"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-tools2"
  depends_on "gz-utils4"
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "sqlite"
  depends_on "tinyxml2"
  depends_on "zeromq"

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
      rpath(source: libexec/"gz/transport15", target: lib),
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
    system libexec/"gz/transport15/gz-transport-service"
    system libexec/"gz/transport15/gz-transport-topic"
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
      find_package(gz-transport QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-transport::gz-transport)
    EOS
    system "pkg-config", "gz-transport"
    cflags = `pkg-config --cflags gz-transport`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-transport",
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
      system python.opt_libexec/"bin/python", "-c", "import gz.transport"
    end
    system Formula["python3"].opt_libexec/"bin/python", "-c", "import gz.transport"
  end
end
