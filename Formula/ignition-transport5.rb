class IgnitionTransport5 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-transport/get/08aa1f3d1d5b2e006dd8b357f3c9367d27f66107.tar.gz"
  version "5.0.0.999~20190711~f2402ae2"
  sha256 "033c35dc3e0338035a8aed6b46418a7caee298c207b72a50b0282031093b404c"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "1e27be12cdbbad34ea203ac0ebbfff7be631576adffe850460f901c6b1716759" => :mojave
    sha256 "926aa8e55337e69ba5fd83f7eb9d441f2dacac9f9e35e4dcbfece2a5db5d2f77" => :high_sierra
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake1"
  depends_on "ignition-msgs2"
  depends_on "ignition-tools"
  depends_on :macos => :high_sierra # c++17
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
        ignition::transport::NodeOptions options;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-transport5 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport5::ignition-transport5)
    EOS
    system "pkg-config", "ignition-transport5"
    cflags = `pkg-config --cflags ignition-transport5`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport5",
                   "-lc++",
                   "-o", "test"
    ENV["IGN_PARTITION"] = rand((1 << 32) - 1).to_s
    system "./test"
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
