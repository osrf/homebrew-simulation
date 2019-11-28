class IgnitionLaunch1 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch-1.4.0.tar.bz2"
  sha256 "324aee0b8a961ed08b07e71afbab875dc3be31d96785dcbd4fe9c2e6760bcb3f"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "ff73acba60d88389256236ee66f239fb44313cb87a598dfa3eae259abbbd0d8a" => :mojave
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
