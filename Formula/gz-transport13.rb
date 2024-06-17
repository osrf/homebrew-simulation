class GzTransport13 < Formula
  desc "Transport middleware for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/gz-transport-13.3.0.tar.bz2"
  sha256 "3cf8535902ddeee811d99b4b4139b444f72763e2d83a2e8f3e66ebca1bbb1e10"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-transport.git", branch: "gz-transport13"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "d8a1d4fed856b17f8bb60bc8e7730a834b8504d1e48a6a53fab21f3ccdfe9159"
    sha256 monterey: "5df774affb2917733726b82fdbcb4cd93d382eeffafdcf3ff669712a12ec75bb"
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "pybind11" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "gz-cmake3"
  depends_on "gz-msgs10"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "python@3.12"
  depends_on "tinyxml2"
  depends_on "zeromq"

  def python_cmake_arg
    "-DPython3_EXECUTABLE=#{which("python3")}"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/transport13", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"
    cmake_args << python_cmake_arg

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.12/site-packages").install Dir[lib/"python/*"]
    rmdir prefix/"lib/python"
  end

  test do
    # test CLI executables
    system libexec/"gz/transport13/gz-transport-service"
    system libexec/"gz/transport13/gz-transport-topic"
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
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(gz-transport13 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-transport13::gz-transport13)
    EOS
    system "pkg-config", "gz-transport13"
    cflags = `pkg-config --cflags gz-transport13`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-transport13",
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
    system Formula["python@3.12"].opt_bin/"python3", "-c", "import gz.transport13"
  end
end
