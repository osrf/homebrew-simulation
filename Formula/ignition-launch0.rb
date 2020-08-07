class IgnitionLaunch0 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch-0.2.0.tar.bz2"
  sha256 "5becd254b5e47668e41b2da676bae16c119a856ed2ea0a0de661a555fcd5f685"
  license "Apache-2.0"
  revision 1

  deprecate! date: "2019-09-30"
  disable! date: "2020-08-31"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo1"
  depends_on "ignition-gui1"
  depends_on "ignition-msgs3"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport6"
  depends_on "qt"
  depends_on "sdformat8"
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
