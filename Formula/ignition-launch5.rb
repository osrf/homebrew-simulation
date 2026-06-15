class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/ignition-launch-5.3.1.tar.bz2"
  sha256 "abb724f65e820b04c056ee2e9329bc749dffcd6fc8e481eb9e4f83a719fb5492"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-launch.git", branch: "ign-launch5"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "gz-plugin2" => :test

  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-fuel-tools7"
  depends_on "ignition-gazebo6"
  depends_on "ignition-gui6"
  depends_on "ignition-math6"
  depends_on "ignition-msgs8"
  depends_on "ignition-physics5"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering6"
  depends_on "ignition-tools"
  depends_on "ignition-transport11"
  depends_on "ignition-utils1"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "sdformat12"
  depends_on "tinyxml2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"ignition/launch5", target: lib),
      rpath(source: lib/"ign-launch-5/plugins", target: lib),
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
    system lib/"ignition/launch5/ign-launch"
    # test plugins in subfolders
    %w[joytotwist gazebo-factory gazebo gazebogui].each do |plugin|
      p = lib/"ign-launch-5/plugins/libignition-launch-#{plugin}.dylib"
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
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system "ign", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
