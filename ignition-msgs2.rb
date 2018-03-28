class IgnitionMsgs2 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://bitbucket.org/ignitionrobotics/ign-msgs/get/1bd845eb4add94c6db474a3ca54ce693a0ffac44.tar.gz"
  version "1.99.99~20180327~1bd845e"
  sha256 "e325924a7224e9573fe74d8132ceea6baaa9e925dd419fb5749f0b3d974159e5"

  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  depends_on "cmake"
  depends_on "ignition-cmake1"
  depends_on "ignition-math5"
  depends_on "ignition-tools"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build

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
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-msgs2 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs2::ignition-msgs2)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs2"
    cflags = `pkg-config --cflags ignition-msgs2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs2",
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
