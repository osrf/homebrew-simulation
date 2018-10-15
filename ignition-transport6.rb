class IgnitionTransport6 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport6-6.0.0~pre2.tar.bz2"
  version "6.0.0~pre2"
  sha256 "e37a2f9716d9a195d7614769569dbba9c2dbc7bb9f8d2dc68a5cdaf37fde2da0"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    sha256 "ddd51ca09df20fde0547cbab48ec7de7810edf8bd922f0e1538bc5d750aee1af" => :mojave
    sha256 "ad7ed6276e714d189ae1e9e8a99bec5d4482fedef78aada7232d5526148dc220" => :high_sierra
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-msgs3"
  depends_on "ignition-tools"
  depends_on :macos => :high_sierra   # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "zeromq"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <ignition/transport.hh>
      int main() {
        ignition::transport::Node node;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-transport6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport6::ignition-transport6)
    EOS
    system "pkg-config", "ignition-transport6"
    cflags = `pkg-config --cflags ignition-transport6`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport6",
                   "-lc++",
                   "-o", "test"
    system "./test"
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
