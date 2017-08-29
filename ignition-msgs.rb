class IgnitionMsgs < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ign-msgs/releases/ignition-msgs-0.7.0.tar.bz2"
  sha256 "5e749ddad57e3e471e01cfc240a9602595dc095952cf34436c40864add08b9dc"
  revision 3

  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-msgs/releases"
    sha256 "34e13e459480fc745c600645019cf704206466b16bd6459c74cc89524c851195" => :sierra
    sha256 "1e076f9585389af145a99e3e218d4afcaed1594b73dc8af7599b013e64f0bae0" => :el_capitan
    sha256 "5a1f852c9ba390e4a68fd371576d94a50b21d8585ef54fd5c9983af01f5fab10" => :yosemite
  end

  depends_on "cmake" => :run
  depends_on "ignition-math3"
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
      find_package(ignition-msgs0 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-MSGS_LIBRARIES})
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs0"
    cflags = `pkg-config --cflags ignition-msgs0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs0",
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
