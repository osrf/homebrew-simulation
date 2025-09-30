class GzJetty < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-jetty"
  url "https://osrf-distributions.s3.amazonaws.com/gz-jetty/releases/gz-jetty-1.0.0.tar.bz2"
  sha256 "d20c6d5d1ed8f5c1e7d13dac71a184d8bc3889dfb19e5f691344d3d3885de838"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-jetty.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "71fc98b71190547fa3fb755a83bf1414387ee059deef9a48120a2aa4456c558a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "3fb37b53b6347a4ed14e641077690f537b839f552f8d32aae076381aec770da3"
    sha256 cellar: :any_skip_relocation, sonoma:        "62131b6aa3c1f9958cab4fc45a806089f0fbc055ca0847f409b75e023f9329bb"
  end

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
