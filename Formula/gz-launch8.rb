class GzLaunch8 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://github.com/gazebosim/gz-launch.git", branch: "main"
  version "7.999.999-0-20231016"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-launch.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ffmpeg"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-gui9"
  depends_on "gz-msgs11"
  depends_on "gz-plugin3"
  depends_on "gz-sim9"
  depends_on "gz-tools2"
  depends_on "gz-transport14"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz/launch8", target: lib),
      rpath(source: lib/"gz-launch-8/plugins", target: lib),
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
    system lib/"gz/launch8/gz-launch"
    # test plugins in subfolders
    %w[joytotwist sim-factory sim simgui].each do |plugin|
      p = lib/"gz-launch-8/plugins/libgz-launch-#{plugin}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin3"].opt_libexec/"gz/plugin3/gz-plugin"
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
