class IgnitionAcropolis < Formula
  desc "Ignition acropolis collection"
  homepage "https://bitbucket.org/ignitionrobotics/ign-acropolis"
  url "https://bitbucket.org/ignitionrobotics/ign-acropolis/get/5f3dd9eb70b9.tar.gz"
  version "1.0.0"
  sha256 "87f3f8415f0d3f3603d84b401902587997b0fff26fbdf5637b8ec691c3fc739f"


  head "https://bitbucket.org/ignitionrobotics/ign-acropolis", :branch => "default", :using => :hg

  depends_on :macos => :mojave # c++17
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
  depends_on "pkg-config"
  depends_on "sdformat8"

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end
end
