class IgnitionMsgs1 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ign-msgs/releases/ignition-msgs-1.0.0~pre6.tar.bz2"
  version "1.0.0~pre6"
  sha256 "cfa4f046e1d3bdfc34f801780ca39da10dd9d690fbcd08072fe18699122085db"
  version_scheme 1

  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-msgs/releases"
    sha256 "cc561b92f04f14f6aaa2267d4d58ef206a0a4c051dcd945e68ae469ca58c558a" => :high_sierra
    sha256 "f24ba84c1e08653b5c9178f6201a0d7a80a0c4fa16bf2c12b9cc19ef8b20ed6d" => :sierra
    sha256 "71b9e9c4df48ebf5586088387175e4f67359eeed53fbbb145cc00f5e970fdcb5" => :el_capitan
  end

  depends_on "cmake" => :run
  depends_on "ignition-cmake0"
  depends_on "ignition-math4"
  depends_on "ignition-tools" => :recommended
  depends_on "pkg-config" => :run
  depends_on "protobuf"
  depends_on "protobuf-c" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <ignition/msgs.hh>
      int main() {
        ignition::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS.undent
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-msgs1 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-MSGS_LIBRARIES})
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs1"
    cflags = `pkg-config --cflags ignition-msgs1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs1",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
