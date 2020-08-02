class IgnitionMsgs6 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/ignitionrobotics/ign-msgs"
  url "https://github.com/ignitionrobotics/ign-msgs/archive/48536f710161449ac525edf3693e702c5da7a054.tar.gz"
  version "5.999.999~0~20200802~48536f"
  sha256 "33aa8c96218f24b8f994659a5edb36f460937e46b95c9d53fba1734bbe7e3ab9"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-msgs", :branch => "master"

  depends_on "protobuf-c" => :build
  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on :macos => :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"

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
      find_package(ignition-msgs6 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs6::ignition-msgs6)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs6"
    cflags = `pkg-config --cflags ignition-msgs6`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs6",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
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
