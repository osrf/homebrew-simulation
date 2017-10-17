class IgnitionMsgs1 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://bitbucket.org/ignitionrobotics/ign-msgs/get/9126e615c81b54ff132ad50a0de27ee1646fff21.tar.gz"
  sha256 "1563fbf21d2296e4e888313dd417c226fabd37afeb817a0dc8de5cbfd2fee1e9"

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
