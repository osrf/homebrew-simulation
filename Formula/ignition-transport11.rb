class IgnitionTransport11 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport11-11.4.1.tar.bz2"
  sha256 "f18501cbd5c78b584b3db1960a3049d6ae416bab7f0289af64eadda13d1c5da5"
  license "Apache-2.0"
  revision 42
  version_scheme 1

  head "https://github.com/gazebosim/gz-transport.git", branch: "ign-transport11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 sonoma:  "0afee44e829e3ab683692aacbc252495103134d28b330a7aff71b0f8b6285da5"
    sha256 ventura: "74fb2f80a9ada296a289c6e8e3a8ac29fccc7c0a739b7527a3304c941e7519b9"
  end

  depends_on "doxygen" => [:build, :optional]

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-msgs8"
  depends_on "ignition-tools"
  depends_on "ignition-utils1"
  depends_on macos: :mojave # c++17
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "tinyxml2"
  depends_on "zeromq"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/transport11", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test CLI executables
    system libexec/"gz/transport11/ign-transport-service"
    system libexec/"gz/transport11/ign-transport-topic"
    # build against API
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
    # cflags = `pkg-config --cflags ignition-transport11`.split
    # ldflags = `pkg-config --libs ignition-transport11`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-o", "test"
    # ENV["IGN_PARTITION"] = rand((1 << 32) - 1).to_s
    # system "./test"
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
