class GzLaunch7 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-7.1.0.tar.bz2"
  sha256 "320606c71b6a2cbbcab683cd8569af9145ece157d5ebd23bc80218e8d148cd09"
  license "Apache-2.0"
  revision 5

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "fd4c98c37eba34a7d4741eddb855be5f0e476ffb2895db81019d22d9522b84f1"
    sha256 monterey: "9e7877f1594ebb2152648025803b14c6ea6b334afd15bd0ceecc636e8fc052a2"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ffmpeg"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-gui8"
  depends_on "gz-msgs10"
  depends_on "gz-plugin2"
  depends_on "gz-sim8"
  depends_on "gz-tools2"
  depends_on "gz-transport13"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz/launch7", target: lib),
      rpath(source: lib/"gz-launch-7/plugins", target: lib),
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
    system lib/"gz/launch7/gz-launch"
    # test plugins in subfolders
    %w[joytotwist sim-factory sim simgui].each do |plugin|
      p = lib/"gz-launch-7/plugins/libgz-launch-#{plugin}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
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
