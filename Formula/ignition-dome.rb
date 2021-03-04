class IgnitionDome < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-dome"
  url "https://osrf-distributions.s3.amazonaws.com/ign-dome/releases/ignition-dome-1.0.0.tar.bz2"
  sha256 "cb78ea2fc0f1cb83f2be3e9071d54693e830f715a93c839b8f2ac3692ff7e459"
  license "Apache-2.0"
  revision 2

  head "https://github.com/ignitionrobotics/ign-dome.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "b90450a2d51495fe77b781950c019529bbad804e62641868ddadee3582987c10"
    sha256 cellar: :any, mojave:   "3da85fb0a7d24867c473a9a8a7ce01833bb41d3e52ecd7ce9ae26b3ff4d920c1"
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
