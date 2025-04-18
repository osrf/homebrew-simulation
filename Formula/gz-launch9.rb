class GzLaunch9 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://github.com/gazebosim/gz-launch.git", branch: "main"
  version "8.999.999-0-20250415"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch9"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-fuel-tools10"
  depends_on "gz-gui10"
  depends_on "gz-math8"
  depends_on "gz-msgs11"
  depends_on "gz-physics8"
  depends_on "gz-plugin3"
  depends_on "gz-rendering9"
  depends_on "gz-sim10"
  depends_on "gz-tools2"
  depends_on "gz-transport15"
  depends_on "gz-utils3"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "sdformat15"
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
