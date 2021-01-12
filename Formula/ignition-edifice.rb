class IgnitionEdifice < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-edifice"
  url "https://github.com/ignitionrobotics/ign-edifice/archive/7a87f6d356962a363bbe5d8e64565a283ca9e9a1.tar.gz"
  version "-1.999.999~0~20210112~7a87f6"
  sha256 "91bb623765123f41082dbd75d4777b84f32974f11c88d9c1aa98e1ac7f060d6f"
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-edifice", branch: "main"

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
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
