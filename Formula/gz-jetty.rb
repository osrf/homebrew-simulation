class GzJetty < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-jetty"
  url "https://osrf-distributions.s3.amazonaws.com/gz-jetty/releases/gz-jetty-1.0.0.tar.bz2"
  sha256 "d20c6d5d1ed8f5c1e7d13dac71a184d8bc3889dfb19e5f691344d3d3885de838"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-jetty.git", branch: "main"

  depends_on "cmake" => :build

  depends_on "gz-jetty-cmake"
  depends_on "gz-jetty-common"
  depends_on "gz-jetty-fuel-tools"
  depends_on "gz-jetty-gui"
  depends_on "gz-jetty-launch"
  depends_on "gz-jetty-math"
  depends_on "gz-jetty-msgs"
  depends_on "gz-jetty-physics"
  depends_on "gz-jetty-plugin"
  depends_on "gz-jetty-rendering"
  depends_on "gz-jetty-sdformat"
  depends_on "gz-jetty-sensors"
  depends_on "gz-jetty-sim"
  depends_on "gz-jetty-tools"
  depends_on "gz-jetty-transport"
  depends_on "gz-jetty-utils"
  depends_on "pkgconf"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_path_exists share/"gz/gz-jetty/release_notes.md"
  end
end
