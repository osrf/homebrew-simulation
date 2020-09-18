class IgnitionTransport4 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport4-4.0.0.tar.bz2"
  sha256 "b0d8d3d4b0d4fbb06ed293955f5dfe2f840fe510daec867422676b41fc3824b4"
  license "Apache-2.0"
  revision 8

  head "https://github.com/ignitionrobotics/ign-transport", branch: "ign-transport4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "b88fe30dacc543df8aed9f0be7ff44e1f0d023e0d35a8d625f0dfa83f0ac8b8b" => :mojave
    sha256 "41ad2ffbaede24b264d771e9ac82e601f513b15e5a5f2e52d144b3b8b7e914b5" => :high_sierra
  end

  depends_on "doxygen" => [:build, :optional]

  depends_on "protobuf-c" => :build
  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake0"
  depends_on "ignition-msgs1"
  depends_on "ignition-tools"
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "zeromq"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <ignition/transport.hh>
      int main() {
        ignition::transport::NodeOptions options;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-transport4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport4::ignition-transport4)
    EOS
    system "pkg-config", "ignition-transport4"
    cflags = `pkg-config --cflags ignition-transport4`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport4",
                   "-lc++",
                   "-o", "test"
    ENV["IGN_PARTITION"] = rand((1 << 32) - 1).to_s
    system "./test"
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
