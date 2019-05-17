class IgnitionBlueprint < Formula
  desc "Ignition blueprint collection"
  homepage "https://bitbucket.org/ignitionrobotics/ign-blueprint"
  url "https://osrf-distributions.s3.amazonaws.com/ign-blueprint/releases/ignition-blueprint-1.0.0~pre1.tar.bz2"
  version "1.0.0~pre1"
  sha256 "91e808ca793e4c50d94cd6f9e443708c869526a00d7bc4384ac5c047e2dfb6ff"

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
