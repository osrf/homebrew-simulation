class IgnitionCitadel < Formula
  desc "Ignition Citadel collection"
  homepage "https://bitbucket.org/ignitionrobotics/ign-citadel"
  url "https://osrf-distributions.s3.amazonaws.com/ign-citadel/releases/ignition-citadel-1.0.0.tar.bz2"
  sha256 "e35ceda484b91bf3ece58dd3679df4998a042a5b7442cbd3153f042180e6a03a"
  version_scheme 1

  head "https://bitbucket.org/ignitionrobotics/ign-citadel", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "0caea6003584c2b7a238f3542b922cf74eeb11fb3a1c71f8e57a70000391ea51" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools4"
  depends_on "ignition-gazebo3"
  depends_on "ignition-gui3"
  depends_on "ignition-launch2"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-physics2"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering3"
  depends_on "ignition-sensors3"
  depends_on "ignition-tools"
  depends_on "ignition-transport8"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat9"

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  # Failing test in Mojave
  # test do
  # TODO: improve the testing
  #  system "#{bin}/ign", "gazebo", "--help"
  # end
end
