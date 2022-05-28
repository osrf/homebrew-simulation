class IgnitionCitadel < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-citadel"
  url "https://osrf-distributions.s3.amazonaws.com/ign-citadel/releases/ignition-citadel-1.0.2.tar.bz2"
  sha256 "2b99e7476093e78841c63d4ec348c6cf7c9d650a2e5787011723142c9f917659"
  license "Apache-2.0"
  revision 2
  version_scheme 1

  head "https://github.com/gazebosim/gz-citadel.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "5b18077521af982d193490faff73777ab030a6a8bfecead734de64b9ed2cad34"
    sha256 cellar: :any, catalina: "77128ee99e7547c05a9bb619a9d382278ca6ba087857ad6805a807e3e1a6d0b3"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

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
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "python@3.9"
  depends_on "sdformat9"

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
    yaml_file = share/"ignition/ignition-citadel/gazebodistro/collection-citadel.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
