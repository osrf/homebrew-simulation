class IgnitionLaunch0 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url ""
  version "0.0.0~pre1"
  sha256 ""

  depends_on "cmake"
  depends_on "pkg-config"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo0"
  depends_on "ignition-gui1"
  depends_on "ignition-msgs3"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport6"
  depends_on "sdformat8"
  depends_on "tinyxml2"
  depends_on "qt"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  # No test. Only plugins in the package.
end
