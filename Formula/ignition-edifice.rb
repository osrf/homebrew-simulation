class IgnitionEdifice < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-edifice"
  url "https://osrf-distributions.s3.amazonaws.com/ign-edifice/releases/ignition-edifice-1.0.3.tar.bz2"
  sha256 "2a8208cc80a8934e64ffa9c79c352ff86c51d0b78ff69931259e3d86cf72fea7"
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-edifice.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "5e9a904810a2dd899e76ce9fe0cad0cc53d6d19d8aad36b1a2d3e1cb941f1d61"
    sha256 cellar: :any, catalina: "fd3afb5175ad3f73fda72cd1c37ba4807665388fb01fa54e05963dd5892ce075"
  end

  deprecate! date: "2022-03-31", because: "is past end-of-life date"

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
