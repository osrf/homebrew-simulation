class IgnitionMsgs8 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/gazebosim/gz-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs8-8.6.0.tar.bz2"
  sha256 "4c7c093fff55201dad0df95a7c200ae3092cd2717a53e9f5ebf9d2ad9cddc73b"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "4caf4ff2c1781edc55390829862d0804b8890b92af9b3e4ba3b32fd4013898f4"
    sha256 cellar: :any, catalina: "f5b129e62c5cf033df6a156633dcf98a469a4588aaf1b17f30a808505d6b8bfa"
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
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

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
      find_package(ignition-msgs8 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs8::ignition-msgs8)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs8"
    cflags = `pkg-config --cflags ignition-msgs8`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs8",
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
