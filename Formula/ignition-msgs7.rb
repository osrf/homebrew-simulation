class IgnitionMsgs7 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/ignitionrobotics/ign-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs7-7.1.0.tar.bz2"
  sha256 "0e1ddb73327a863eac027b5e430277e9fa121053aa108cc3d8b9c43c1698af23"
  license "Apache-2.0"
  revision 2

  head "https://github.com/ignitionrobotics/ign-msgs.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "8d30ffb54fcec2cdd2fbfe71f43cb343f1c0b2378cd03a869f4d6301e53e2665"
    sha256 cellar: :any, mojave:   "8ad1faf95cc73381fef54dabe5c11b7835212287485078b58f2d8806e169e51b"
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
