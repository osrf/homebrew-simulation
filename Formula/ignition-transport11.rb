class IgnitionTransport11 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://github.com/ignitionrobotics/ign-transport/archive/36308c1cc2dd84e4ebf94449ea9d83a62662c555.tar.gz"
  version "10.999.999~0~20210413~36308c"
  sha256 "eaff16c64487debe2418c90f46d2f9fe020b671176b93ed547ebdf93f2c8a51b"
  license "Apache-2.0"
  revision 1
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-transport.git", branch: "main"

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-msgs8"
  depends_on "ignition-tools"
  depends_on "ignition-utils1"
  depends_on macos: :mojave # c++17
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
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-transport11 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport11::ignition-transport11)
    EOS
    system "pkg-config", "ignition-transport11"
    cflags = `pkg-config --cflags ignition-transport11`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport11",
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
