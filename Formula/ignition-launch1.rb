class IgnitionLaunch1 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch-1.4.2.tar.bz2"
  sha256 "0e4a67f439a4c908fbb730c3c5aa0c6d580309a820640d90d4e45cf45b73d1c2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "e7d11dbcda05fe75c373cb0637c053b58f2346d17fb6e85ec560bc452375a0e2" => :mojave
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

  # TODO: fix test. Failing: https://build.osrfoundation.org/job/generic-release-homebrew_bottle_builder/209/label=osx_mojave/
  # test do
  #  system "ignition", "-run", "config/gazebo.ign"
  #  # check for Xcode frameworks in bottle
  #  cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
  #  system cmd_not_grep_xcode
  # end
end
