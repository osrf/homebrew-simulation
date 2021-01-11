class IgnitionEdifice < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-edifice"
  url "https://github.com/ignitionrobotics/ign-edifice/archive/be4570f0b4757445ff77496cb30d4ceb940e8baf.tar.gz"
  sha256 "2da4c054c562fb3703ada530dc04fb92705a73df30e2d2c39d4dd5e01e8800e9"
  license "Apache-2.0"
  revision 1

  head "https://github.com/ignitionrobotics/ign-edifice", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "4779990cad87ab7545bb338d0852707e5a5074f2883382606021fbeff9f293a0" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools6"
  depends_on "ignition-gazebo5"
  depends_on "ignition-gui5"
  depends_on "ignition-launch4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs7"
  depends_on "ignition-physics3"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering5"
  depends_on "ignition-sensors5"
  depends_on "ignition-tools"
  depends_on "ignition-transport10"
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
    yaml_file = share/"ignition/ignition-edifice/gazebodistro/collection-edifice.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
