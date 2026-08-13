class IgnitionTransport11 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/ignition-transport-11.4.2.tar.bz2"
  sha256 "5cb9a6a70d1c71e4bc60970e494b3ba82ecece757ccaa637c43b2193d4c15c72"
  license "Apache-2.0"
  revision 10
  version_scheme 1

  head "https://github.com/gazebosim/gz-transport.git", branch: "ign-transport11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "9708580682b2855e8cfa34c434d61d97d3d66d8ffa3e9529e63375dd231900e6"
    sha256 arm64_sonoma:  "08ea9a8502e4c507f3e43154b7c879fa7ddd6ed306fc14c9a669a65b4146e9ad"
    sha256 sonoma:        "67b3f57c86557213c0e48bcf56cd2def9486bb7bd9065c2bf78a1e7f18d697e9"
  end

  depends_on "doxygen" => [:build, :optional]

  depends_on "abseil"
  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-msgs8"
  depends_on "ignition-tools"
  depends_on "ignition-utils1"
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "sqlite"
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
