class IgnitionMsgs5 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/gazebosim/gz-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/ignition-msgs-5.11.1.tar.bz2"
  sha256 "48fb5cd7859203fdcf31ca0aa6405c58893aefd59025b9380d8fae6627cc41ec"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "ign-msgs5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "342cb6c8d95a79aeafa3096247d536fe8bfb9d727c6e33cbd3f3fbd0fc247ddc"
    sha256 cellar: :any, ventura: "498d2488303d8eb67484d9c7c15203601fe3d1ce5828f3bcfec7bb8ee57e46b9"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on macos: :high_sierra # c++17
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
      find_package(ignition-msgs5 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs5::ignition-msgs5)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs5"
    # cflags = `pkg-config --cflags ignition-msgs5`.split
    # ldflags = `pkg-config --libs ignition-msgs5`.split
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
