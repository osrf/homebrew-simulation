class GzJetty < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-jetty"
  url "https://github.com/gazebosim/gz-jetty.git", branch: "main"
  version "0.999.999-0-20250516"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-jetty.git", branch: "main"

  depends_on "cmake" => :build

  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-fuel-tools11"
  depends_on "gz-gui10"
  depends_on "gz-launch9"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-physics9"
  depends_on "gz-plugin4"
  depends_on "gz-rendering10"
  depends_on "gz-sensors10"
  depends_on "gz-sim10"
  depends_on "gz-tools2"
  depends_on "gz-transport15"
  depends_on "gz-utils4"
  depends_on "pkgconf"
  depends_on "sdformat16"

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
