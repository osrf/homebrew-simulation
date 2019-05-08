class IgnitionBlueprint < Formula
  desc "Ignition blueprint collection"
  homepage "https://bitbucket.org/ignitionrobotics/ign-blueprint"
  url "https://bitbucket.org/ignitionrobotics/ign-blueprint/get/7684ca620f67e07a3436d012ad050bd6b8434b87.tar.bz2"
  version "0.999.999~20190508~7684ca62"
  sha256 "58fc013af075956fe7ae0e90d979bc3da6f20d1516627a0b7115c5760ef3659a"

  head "https://bitbucket.org/ignitionrobotics/ign-blueprint", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools3"
  depends_on "ignition-gazebo2"
  depends_on "ignition-gui2"
  depends_on "ignition-launch1"
  depends_on "ignition-math6"
  depends_on "ignition-msgs4"
  depends_on "ignition-physics1"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering2"
  depends_on "ignition-sensors2"
  depends_on "ignition-tools"
  depends_on "ignition-transport7"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat8"

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
  # Failing test in mojave https://build.osrfoundation.org/job/generic-release-homebrew_bottle_builder/label=osx_mojave/211/console
end
