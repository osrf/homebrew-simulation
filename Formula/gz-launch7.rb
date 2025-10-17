class GzLaunch7 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-7.1.1.tar.bz2"
  sha256 "e29f8b4663474cfed1364c45afa3aee8b44d816ffe1679c26c699f7c805cdffd"
  license "Apache-2.0"
  revision 18

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "ffd30920645acf5ad953e3d3578d7d4d237ab38cdfc3dcdf5761c4114cee0e40"
    sha256 arm64_sonoma:  "35b91f43bd26d8240f0ef49a81928951c0e67dfe0a2dee1d69a87ebf37010e47"
    sha256 sonoma:        "2d2a287459474bfc67dabde122b591f8aecdeb20a9f275172ededc0f33cd01b4"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-fuel-tools9"
  depends_on "gz-gui8"
  depends_on "gz-math7"
  depends_on "gz-msgs10"
  depends_on "gz-physics7"
  depends_on "gz-plugin2"
  depends_on "gz-rendering8"
  depends_on "gz-sim8"
  depends_on "gz-tools2"
  depends_on "gz-transport13"
  depends_on "gz-utils2"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "sdformat14"
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
