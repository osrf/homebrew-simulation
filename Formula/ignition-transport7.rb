class IgnitionTransport7 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-transport/get/058443d6e8f961268e5f4d310cb5ef0fb672228c.tar.gz"
  version "6.999.999~1~20190410~058443d"
  sha256 "1e45664aceb2819bc323bd28f534626165c8c6933a6fe5aa890184960221961d"

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-msgs4"
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
        ignition::transport::Node node;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-transport7 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport7::ignition-transport7)
    EOS
    system "pkg-config", "ignition-transport7"
    cflags = `pkg-config --cflags ignition-transport7`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport7",
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
