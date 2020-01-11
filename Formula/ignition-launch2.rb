class IgnitionLaunch2 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch2-2.0.1.tar.bz2"
  sha256 "bd6cde64dad45471527c60cefebd2631879179aa77d4ec2bc283eaed5da8884e"

  head "https://bitbucket.org/ignitionrobotics/ign-launch", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "a64610137063b702dc2818ee2379033f3acf5e58ce4af7ec59735c57a5001de8" => :mojave
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
