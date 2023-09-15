class GzTransport12 < Formula
  desc "Transport middleware for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/gz-transport-12.2.0.tar.bz2"
  sha256 "731ec9f87fd815c62486ed4e2c3ecbeff5b8b4a8f09cc5e7abf4d8758cebe048"
  license "Apache-2.0"
  revision 12

  head "https://github.com/gazebosim/gz-transport.git", branch: "gz-transport12"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "e2277d2560c81e2478f865359b45a9e0a61c30841fc29a1540d6923270832070"
    sha256 monterey: "4cd9f47d9db13508c172e3c8fcb9dce8f3563018db1ae862aa6be2850760e727"
    sha256 big_sur:  "898238b0bf771ba7420f0190b4f7e615e8899a8bc6120b328d4267caee7d5d79"
  end

  depends_on "doxygen" => [:build, :optional]

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

  patch do
    # Fix for compatibility with protobuf 23.2
    url "https://github.com/gazebosim/gz-transport/commit/8f7441a7fdf2c8681cae55b3f93c3df4cbe649c3.patch?full_index=1"
    sha256 "8c9ae5e66743077d9172aee4ae89ae9555b0641857c979cb77aaca8dee010929"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/transport12", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test CLI executables
    system libexec/"gz/transport12/gz-transport-service"
    system libexec/"gz/transport12/gz-transport-topic"
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
      find_package(gz-transport12 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-transport12::gz-transport12)
    EOS
    system "pkg-config", "gz-transport12"
    # cflags = `pkg-config --cflags gz-transport12`.split
    # ldflags = `pkg-config --libs gz-transport12`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-o", "test"
    ENV["GZ_PARTITION"] = rand((1 << 32) - 1).to_s
    # system "./test"
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
