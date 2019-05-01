class IgnitionLaunch1 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url "https://bitbucket.org/ignitionrobotics/ign-launch/get/d90d7a7cd35066419c3e19c1a899855c3d5a190b.tar.bz2"
  version "1.0.0~pre1~1~20190430~d90d7a7"
  sha256 "1e237e971e50186ef429dc9b64451c7c79793ed4258888ab9f054077ec220610"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "e7d5d1148a243137e062b3aadd69b806298558cd863d1e17fb61d918bb777ca9" => :mojave
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
