class IgnitionMsgs8 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/gazebosim/gz-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/ignition-msgs-8.7.1.tar.bz2"
  sha256 "5de8edbcf971ea223756310129b2a25c0b5cba2657d736fd8f556eeec331bff0"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "ign-msgs8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "e936c4577982f838cd956236c0823d4d2c4e9a378011d4151846ad42294f7c1a"
    sha256 cellar: :any, arm64_sonoma:  "5287018abc8a7eb49b67149b1b452af251af961b4018c3a1c8de9dcbf9859954"
    sha256 cellar: :any, sonoma:        "8bfe2ee56977b8cc64879245ce85502b408eca71c0e2d30aa0fd3b7787bddd9d"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
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
      find_package(ignition-msgs8 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs8::ignition-msgs8)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs8"
    # cflags = `pkg-config --cflags ignition-msgs8`.split
    # ldflags = `pkg-config --libs ignition-msgs8`.split
    # compilation is broken with pkg-config, disable for now
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-o", "test"
    # system "./test"
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
