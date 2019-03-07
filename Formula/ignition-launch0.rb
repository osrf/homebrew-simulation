class IgnitionLaunch0 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-launch"
  url "https://bitbucket.org/ignitionrobotics/ign-launch/get/779f41bf57be18f470fe50cc2cd7f8f67fd497b4.tar.gz"
  version "0.0.0~pre1"
  sha256 "e13273fa38e98bb5127457c7e8acae6d70cde88ab4e90b00d67d365c212f0697"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo0"
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

  test do
    system "ignition", "-run", "config/gazebo.ign"
  end
end
