class IgnitionMsgs1 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://bitbucket.org/ignitionrobotics/ign-msgs/get/cd27f8476eb9e4f7a41c1ab1d37dbadc69fd7f24.tar.gz"
  version "0.9.9~20171031~ cd27f84"
  sha256 "51fe7d48c3be01305a7bc379119151f16b3b05e1c4b1bc6a418afb6383f8b550"

  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  #bottle do
  #  root_url "http://gazebosim.org/distributions/ign-msgs/releases"
  #  sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :high_sierra
  #  sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :sierra
  #  sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :el_capitan
  #end

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
