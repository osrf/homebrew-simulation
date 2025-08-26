class IgnitionMsgs8 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://github.com/gazebosim/gz-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs8-8.7.0.tar.bz2"
  sha256 "b17a8e16fe56a84891bd0654a2ac09427e9a567b9cd2255bb2cfa830f8e1af45"
  license "Apache-2.0"
  revision 55

  head "https://github.com/gazebosim/gz-msgs.git", branch: "ign-msgs8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sonoma: "fa4eb5b6c0567dcda437169049636d89e081a9db8a3265c0258d19e79af4a45b"
    sha256 cellar: :any, sonoma:       "40f094bec1f825a9b9818e86336bf45336e197d71cdca043b08955dbfd8b7685"
    sha256 cellar: :any, ventura:      "34f68aa8fa8d35274da9c675021fa53389602b6908c17174fd51253b15fa6cac"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on macos: :high_sierra # c++17
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "tinyxml2"

  patch do
    # Fix for compatibility with protobuf 23.2
    url "https://github.com/gazebosim/gz-msgs/commit/0c0926c37042ac8f5aeb49ac36101acd3e084c6b.patch?full_index=1"
    sha256 "02dd3ee467dcdd1b5b1c7c26d56ebea34276fea7ff3611fb53bf27b99e7ba4bc"
  end

  patch do
    # Fix for compatibility with protobuf 30
    url "https://github.com/gazebosim/gz-msgs/commit/01f6ee53c20e1d5a5dece1b60e98c78cdbc1ea6c.patch?full_index=1"
    sha256 "4aab8b47f83757014c56f1aac3f3da147d828dc6a935c09618e673424778084e"
  end

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
