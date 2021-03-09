class IgnitionMsgs7 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/ignitionrobotics/ign-msgs"
  url "https://github.com/ignitionrobotics/ign-msgs/archive/53e5fcc8fff54832660b76cb2301daed1418a7c9.tar.gz"
  version "6.999.999~0~20210309~53e5fc"
  sha256 "5714046ad2bac0f622f9c97286779e9fd97fd3043e85df63aed119668b935178"
  license "Apache-2.0"
  revision 1

  head "https://github.com/ignitionrobotics/ign-msgs.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "70d596625168c84c4afd0a9f77e287a87abe9e670e0daf62282908581bc8f467"
    sha256 cellar: :any, mojave:   "cc5bf76221584eb5a958b01f3fa3e2022c25be3839d18e25496f49b03bfa8c43"
  end

  depends_on "protobuf-c" => :build
  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

    system "cmake", ".", *cmake_args
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
      find_package(ignition-msgs7 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs7::ignition-msgs7)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs7"
    cflags = `pkg-config --cflags ignition-msgs7`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs7",
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
