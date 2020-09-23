class IgnitionDome < Formula
  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-dome"
  url "https://osrf-distributions.s3.amazonaws.com/ign-dome/releases/ignition-dome-1.0.0~pre1.tar.bz2"
  version "1.0.0~pre1"
  sha256 "98cf7fa6a0ed81107551cf0622827cff71f7cbc50deeef4282be4d4e48e6a66d"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-dome", branch: "master"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "4a1d3c5da674adaf0f966d42a34cee1aae56a2fcfe474697eb0baa24a7fdcf7a" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools5"
  depends_on "ignition-gazebo4"
  depends_on "ignition-gui4"
  depends_on "ignition-launch3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs6"
  depends_on "ignition-physics3"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering4"
  depends_on "ignition-sensors4"
  depends_on "ignition-tools"
  depends_on "ignition-transport9"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat10"

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
