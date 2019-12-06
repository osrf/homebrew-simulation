class IgnitionLaunch2 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch2-2.0.0~pre3.tar.bz2"
  version "2.0.0~pre3"
  sha256 "4024896aab0b0e2b9ad80ea7157d66b9912d323d65167cc030cc48baf87d1c7e"

  head "https://bitbucket.org/ignitionrobotics/ign-launch", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "beec77815e4cf1b807795ec9790a926bf1205c835015430f243651e29d76c043" => :mojave
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
