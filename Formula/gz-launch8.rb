class GzLaunch8 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-8.0.2.tar.bz2"
  sha256 "e0ccbd1bc83bc5f178a7a0dc76d1f40e788d5bcad1aeb488c2364ea46466f24e"
  license "Apache-2.0"
  revision 11

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "38df1c3bc5ac4a9bf9ab280a0b4fc662f2550ae670b23a9eadcb7aecf1d65742"
    sha256 arm64_sonoma:  "7fabc329b037ad50b533cabdf7b4bb75376fdea0c6967f860c7bf70fb540e571"
    sha256 sonoma:        "583114535011a7242b52949b2ab41d4f63ea95a8cc924517307514715104f93e"
  end

  # head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch8"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "fmt"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-fuel-tools10"
  depends_on "gz-gui9"
  depends_on "gz-math8"
  depends_on "gz-msgs11"
  depends_on "gz-physics8"
  depends_on "gz-plugin3"
  depends_on "gz-rendering9"
  depends_on "gz-sim9"
  depends_on "gz-tools2"
  depends_on "gz-transport14"
  depends_on "gz-utils3"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "sdformat15"
  depends_on "spdlog"
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
