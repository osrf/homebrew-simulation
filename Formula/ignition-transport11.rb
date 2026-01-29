class IgnitionTransport11 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-transport/releases/ignition-transport-11.4.2.tar.bz2"
  sha256 "5cb9a6a70d1c71e4bc60970e494b3ba82ecece757ccaa637c43b2193d4c15c72"
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/gazebosim/gz-transport.git", branch: "ign-transport11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "8b4dd7cb3f74f9414738ccc44b8b1a5330ef24c29c4045a3bb24b76488d4575b"
    sha256 arm64_sonoma:  "7e1843e05b1dd6aaafc20ad5a498ffaeea09dee006fa6c74591eec6d67782ab3"
    sha256 sonoma:        "9f003b2578e24aa687e87e75342b1748bf2ab953228ae12a6d753d248b1e1db4"
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

  patch do
    # Fix for compatibility with protobuf 28
    url "https://github.com/gazebosim/gz-transport/commit/9ea158bf31c62c1bbd9330aec281b4debc12938f.patch?full_index=1"
    sha256 "60864aaa2876c80f16afe6d93a906b417ceb18a4c3d535d5d780c275853e4a83"
  end

  patch do
    # Fix for compatibility with protobuf 30
    url "https://github.com/gazebosim/gz-transport/commit/dec5411d7032478ac86c1c902ebecb6c2d8cd1a8.patch?full_index=1"
    sha256 "43e448c9bd51c5bd1bbbdf9cce615d803ddb59f8420095f15a5d78124daeaf51"
  end

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
