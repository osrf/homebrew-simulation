class IgnitionGarden < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-garden"
  url "https://github.com/ignitionrobotics/ign-garden/archive/a4732212255ef447f102587a346086fc11c1846c.tar.gz"
  version "0.999.999~0~20211008~a47322"
  sha256 "2f0fa319ba90f3840521b2d8544bd4528e3a2cf39c9899638e6ec3b6a6231226"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-garden.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "67e6a3f6c421969c0a14070889cf30cf3e3bc8b05733683e04c6b2df5f67d5ca"
    sha256 cellar: :any, catalina: "d148602e0dbe37b1212997f44420b335c6ab2c044b946727bcecf1e39b7315c5"
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-fuel-tools7"
  depends_on "ignition-gazebo6"
  depends_on "ignition-gui6"
  depends_on "ignition-launch5"
  depends_on "ignition-math6"
  depends_on "ignition-msgs8"
  depends_on "ignition-physics5"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering6"
  depends_on "ignition-sensors6"
  depends_on "ignition-tools"
  depends_on "ignition-transport11"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat12"

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
    yaml_file = share/"ignition/ignition-garden/gazebodistro/collection-garden.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
