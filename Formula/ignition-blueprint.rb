class IgnitionBlueprint < Formula
  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-blueprint"
  url "https://osrf-distributions.s3.amazonaws.com/ign-blueprint/releases/ignition-blueprint-1.0.0.tar.bz2"
  sha256 "a55860fa37bfb0c357ca86aaa31cd5de42e5f8f9022bced3e827808785e83041"
  revision 3

  head "https://github.com/ignitionrobotics/ign-blueprint", branch: "master"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "9684a232138ca5ab9e55a3a5d5f95a8d559a89151c4a792a275f5ef959a8ef07" => :mojave
  end

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
  depends_on macos: :mojave # c++17
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
