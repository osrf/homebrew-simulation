class GzTransport12 < Formula
  desc "Transport middleware for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/gz-transport-12.0.0.tar.bz2"
  sha256 "5b49397cb4d31aa870f3c837f8c7393301ddc03ff7b45240b67570fd9c634f1a"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-transport.git", branch: "gz-transport12"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "b2c7fa076bfa48e2de6bd5e7e427bc8728bc0fdf8da570f91d620f3994cacfa8"
    sha256 catalina: "3ea54104a57c49eb1f1f9620887729189b357838cf32e30d38c738bfdf28bdee"
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "gz-cmake3"
  depends_on "gz-msgs9"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "zeromq"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"


    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
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
      find_package(gz-transport12 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-transport12::gz-transport12)
    EOS
    system "pkg-config", "gz-transport12"
    cflags = `pkg-config --cflags gz-transport12`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-transport12",
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
  end
end
