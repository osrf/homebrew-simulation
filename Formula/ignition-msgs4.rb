class IgnitionMsgs4 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs4-4.7.0.tar.bz2"
  sha256 "3bbf7b30425a811191f8c0a7549942a81ded05af80521801937bf2eeb9c222b1"
  revision 3

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "7bd127bdbb7b1b5963b7b5ccaa42ab1014df5277ca923695b7d8c6756b73eab2" => :mojave
    sha256 "f03260dd0a4ff9bea20c364fbf605c2c291c1b47816c38d651e53da0946c8a1e" => :high_sierra
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
      find_package(ignition-msgs4 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs4::ignition-msgs4)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs4"
    cflags = `pkg-config --cflags ignition-msgs4`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs4",
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
