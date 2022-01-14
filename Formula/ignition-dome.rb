class IgnitionDome < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-dome"
  url "https://osrf-distributions.s3.amazonaws.com/ign-dome/releases/ignition-dome-1.0.1.tar.bz2"
  sha256 "b6d6607cc53faed16f005ccb40b28ee7295b0ec9b8095062bbccde9a2490f888"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-dome.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "48afc6c5e95861b6ceedb789085cb470cbb66ecf5c00517f4a3072a9888c1f5a"
    sha256 cellar: :any, catalina: "38c6d11f6790d3f17f9832e8216d3eee22b1aaff41a3a4709d4513bab1b5dcee"
  end

  disable! date: "2022-02-28", because: "is past end-of-life date"
  deprecate! date: "2021-12-31", because: "is past end-of-life date"

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

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/64/c2/b80047c7ac2478f9501676c988a5411ed5572f35d1beff9cae07d321512c/PyYAML-5.3.1.tar.gz"
    sha256 "b8eac752c5e14d3eca0e6dd9199cd627518cb5ec06add0de9d32baeee6fe645d"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    venv = virtualenv_create(libexec, Formula["python@3.9"].opt_bin/"python3")
    %w[PyYAML vcstool].each do |pkg|
      venv.pip_install pkg
    end
  end

  test do
    yaml_file = share/"ignition/ignition-dome/gazebodistro/collection-dome.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
