class GzLaunch9 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-9.0.1.tar.bz2"
  sha256 "096f66cd2a5b58dc8ca93e9bc33c65e0cf82af7472f154fc2d8a955bc762cd5f"
  license "Apache-2.0"
  revision 10

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "2a7403a96c7687b77de847c3bc0cb8d1371e55dc0ec18d86670dfe0411d0cf35"
    sha256 arm64_sonoma:  "c445f76cc20928cf56f15da2f0d7a5ef4afe700c7dda617bc1fa7f939b7d198d"
    sha256 sonoma:        "86158e8524f03898e1d7a9aeff3df443cc1dd95a33b6eecae00137183f3fbeb6"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "fmt"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-fuel-tools11"
  depends_on "gz-gui10"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-physics9"
  depends_on "gz-plugin4"
  depends_on "gz-rendering10"
  depends_on "gz-sim10"
  depends_on "gz-tools2"
  depends_on "gz-transport15"
  depends_on "gz-utils4"
  depends_on "libwebsockets"
  depends_on "protobuf"
  depends_on "qtbase"
  depends_on "qtdeclarative"
  depends_on "sdformat16"
  depends_on "spdlog"
  depends_on "tinyxml2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz/launch9", target: lib),
      rpath(source: lib/"gz-launch-9/plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    require "system_command"
    extend SystemCommand::Mixin

    # test CLI executable
    system lib/"gz/launch9/gz-launch"
    # test plugins in subfolders
    %w[joytotwist sim-factory sim simgui].each do |plugin|
      p = lib/"gz-launch-9/plugins/libgz-launch-#{plugin}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = formula_opt_libexec("gz-plugin4")/"gz/plugin4/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    end
    ENV["GZ_CONFIG_PATH"] = "#{opt_share}/gz"
    system "gz", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
