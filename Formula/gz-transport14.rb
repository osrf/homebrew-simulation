class GzTransport14 < Formula
  desc "Transport middleware for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/gz-transport-14.0.0~pre1.tar.bz2"
  version "14.0.0-pre1"
  sha256 "756c13d7fd69630a7e329b1a8e4443f9840524bd4b637697f1a334e53046b18e"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-transport.git", branch: "gz-transport14"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "088d07d3aa63d03ace09456c3b22b7d2857f93cabfa98d46b14abc199686172f"
    sha256 monterey: "a4a07b4a1f27190b48af53d6cf309a9fd148690b60e06c1f778006603656b428"
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "pybind11" => :build

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
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "python@3.12"
  depends_on "sqlite"
  depends_on "tinyxml2"
  depends_on "zeromq"

  def python_cmake_arg
    "-DPython3_EXECUTABLE=#{which("python3")}"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/transport14", target: lib),
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
    system Formula["python@3.12"].opt_bin/"python3.12", "-c", "import gz.transport14"
  end
end
