class GzLaunch9 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-9.0.0.tar.bz2"
  sha256 "7d8452a98aaf3d9f6f8d417178e52347b8c3505edca38d4525ab1ceb314c25a6"
  license "Apache-2.0"
  revision 10

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "2d5ce12c5244ce940b1be0f9c6b80ade26dbbbc166d51d429936a4a9bc1d86f2"
    sha256 arm64_sonoma:  "deb27bda8c672b18af3b36e22d8ccaffe4cc6433c7ea8578984250dd54d0e6bc"
    sha256 sonoma:        "7f822e2c81bda97f6e776db3bd9929388e0cd75f2292d7ba2f4f732be9217688"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "ffmpeg"
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
  depends_on "protobuf"
  depends_on "qt@6"
  depends_on "sdformat16"
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
