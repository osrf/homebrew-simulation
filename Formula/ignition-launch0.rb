class IgnitionLaunch0 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch-0.2.0.tar.bz2"
  sha256 "5becd254b5e47668e41b2da676bae16c119a856ed2ea0a0de661a555fcd5f685"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "e7d5d1148a243137e062b3aadd69b806298558cd863d1e17fb61d918bb777ca9" => :mojave
  end

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
