class IgnitionAcropolis < Formula
  desc "Ignition acropolis collection"
  homepage "https://bitbucket.org/ignitionrobotics/ign-acropolis"
  url "https://osrf-distributions.s3.amazonaws.com/ign-acropolis/releases/ignition-acropolis-1.0.1.tar.bz2"
  sha256 "1d4c81e08bea92f508cd71b7a2af22f0111f205799f888eac6aa8c665e0260fe"

  head "https://bitbucket.org/ignitionrobotics/ign-acropolis", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "431730f4844ee511c4514603558477362ef922dd7adf0355eac33b0da9866939" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools3"
  depends_on "ignition-gazebo1"
  depends_on "ignition-gui1"
  depends_on "ignition-launch0"
  depends_on "ignition-math6"
  depends_on "ignition-msgs3"
  depends_on "ignition-physics1"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering1"
  depends_on "ignition-sensors1"
  depends_on "ignition-tools"
  depends_on "ignition-transport6"
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
