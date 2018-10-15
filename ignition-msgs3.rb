class IgnitionMsgs3 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ign-msgs/releases/ignition-msgs3-3.0.0~pre2.tar.bz2"
  version "3.0.0~pre2"
  sha256 "cb151771c5ee052ca56c267b1e53cb5a9bb18c49617343103ab522bab8361f7a"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-msgs/releases"
    cellar :any
    sha256 "0f431d04a8888d352edf3c5efbdcf268e0b28612b597024b86182192cd9357b9" => :mojave
    sha256 "24963d16a5ecda16e93093a9b2ba1a2fccaa3a69231bbd8577d3cdc5532a2877" => :high_sierra
  end

  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on :macos => :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/msgs.hh>
      int main() {
        ignition::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-msgs3 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs3::ignition-msgs3)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs3"
    cflags = `pkg-config --cflags ignition-msgs3`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs3",
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
