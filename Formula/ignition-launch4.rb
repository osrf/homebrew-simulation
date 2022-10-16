class IgnitionLaunch4 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch4-4.1.0.tar.bz2"
  sha256 "fd1e5a535bafb197360b168bce573bed3c4d7804b76c098d93afc5b17b2bdcef"
  license "Apache-2.0"
  revision 6

  head "https://github.com/gazebosim/gz-launch.git", branch: "main"

  disable! date: "2022-11-01", because: "is past end-of-life date"
  deprecate! date: "2022-03-31", because: "is past end-of-life date"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ffmpeg"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-gazebo5"
  depends_on "ignition-gui5"
  depends_on "ignition-msgs7"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport10"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system "ign", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
