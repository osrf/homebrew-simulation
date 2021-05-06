class IgnitionLaunch3 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch3-3.3.0.tar.bz2"
  sha256 "fb556e23a5dd9132164c237de0295d1bbffa692d2245d6edca93df68ab214eeb"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "ign-launch3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "c30e5777bc57f1da4858b41a1b159a1aca71b3d626ebf8031089b5da655c93e7"
    sha256 mojave:   "8a5c4d3287d8fa41398aa8292b91bce5aeeaf08457a7ff7a648093d130b977dc"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo4"
  depends_on "ignition-gui4"
  depends_on "ignition-msgs6"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport9"
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
