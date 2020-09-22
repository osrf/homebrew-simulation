class IgnitionTransport9 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport9-9.0.0~pre2.tar.bz2"
  version "9.0.0~pre2"
  sha256 "2b20c14ce1dd9b10001b6eca128239228fb31990ee3aabdc15b91c2ff816434f"
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-transport", branch: "master"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "fb91039a6fe303a4444415538e1412b3e840aedde51a565ff823892c88910f43" => :mojave
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-msgs6"
  depends_on "ignition-tools"
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
      find_package(ignition-transport9 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport9::ignition-transport9)
    EOS
    system "pkg-config", "ignition-transport9"
    cflags = `pkg-config --cflags ignition-transport9`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport9",
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
