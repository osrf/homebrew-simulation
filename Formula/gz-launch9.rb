class GzLaunch9 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-9.0.0.tar.bz2"
  sha256 "7d8452a98aaf3d9f6f8d417178e52347b8c3505edca38d4525ab1ceb314c25a6"
  license "Apache-2.0"
  revision 12

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "94167c5d1ce543bbf7d0b0b8d50c856c725d801b355c2b2f6e73c8bd22f7a777"
    sha256 arm64_sonoma:  "e2ff1d574215f5655211900fdb577e0f5c250418ed8976421468b4f60494a47d"
    sha256 sonoma:        "4dd4df58634997e3f57b3d280ec1300c16104a5f4ad98aa951b61490de65bb6f"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "fmt"
  depends_on "gz-jetty-cmake"
  depends_on "gz-jetty-common"
  depends_on "gz-jetty-fuel-tools"
  depends_on "gz-jetty-gui"
  depends_on "gz-jetty-math"
  depends_on "gz-jetty-msgs"
  depends_on "gz-jetty-physics"
  depends_on "gz-jetty-plugin"
  depends_on "gz-jetty-rendering"
  depends_on "gz-jetty-sdformat"
  depends_on "gz-jetty-sim"
  depends_on "gz-jetty-tools"
  depends_on "gz-jetty-transport"
  depends_on "gz-jetty-utils"
  depends_on "libwebsockets"
  depends_on "protobuf"
  depends_on "qt@6"
  depends_on "qtbase"
  depends_on "qtdeclarative"
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
      cmd = Formula["gz-plugin4"].opt_libexec/"gz/plugin4/gz-plugin"
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
