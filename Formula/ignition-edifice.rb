class IgnitionEdifice < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-edifice"
  url "https://github.com/ignitionrobotics/ign-edifice/archive/fa1d69f55ced450aca095d55105eea2f04f6857e.tar.gz"
  version "0.999.999~0~20210122~fa1d69"
  sha256 "8b252a9034489c4ede8bdfc9e7688c0b7165744d8aa650d41ffe9a4baf930217"
  license "Apache-2.0"
  revision 1
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-edifice.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "daeeb329592598b8c7e93a6ad4b27fa613d6d0c0076d6240825fb2c7a2871124"
    sha256 cellar: :any, mojave:   "f53faa7ad8d45d0ec44ef04b95fae4e412e52e5c8714731e7380bf888af142ce"
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-fuel-tools6"
  depends_on "ignition-gazebo5"
  depends_on "ignition-gui5"
  depends_on "ignition-launch4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs7"
  depends_on "ignition-physics4"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering5"
  depends_on "ignition-sensors5"
  depends_on "ignition-tools"
  depends_on "ignition-transport10"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat11"

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
