class IgnitionLaunch2 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch2-2.2.2.tar.bz2"
  sha256 "121c1a63c519709c057bb2b6d2688b9e8ebe07aa5de2d62205857a7028339779"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "ign-launch2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "ff4709d783c60f1476740b94cc50e80aa33e717e3cf5ca6ef1094fc6552791c4"
    sha256 catalina: "a4d7e16fc9c3f02e6730c04e0d2c7bf971df3381dde44f47483c1e3970108217"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo3"
  depends_on "ignition-gui3"
  depends_on "ignition-msgs5"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport8"
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
