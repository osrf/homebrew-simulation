class IgnitionLaunch1 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch-1.10.0.tar.bz2"
  sha256 "04a52aef4e3d261432732647415d30ea1e53abb1cf2b87aace0d65703c811b5c"
  license "Apache-2.0"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "89f281e5b8e9f15a800858c668043f2ba237149e1760c851abe3545c0be7f63d" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo2"
  depends_on "ignition-gui2"
  depends_on "ignition-msgs4"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport7"
  depends_on "qt"
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
