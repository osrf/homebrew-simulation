class IgnitionFortress < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-fortress"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fortress/releases/ignition-fortress-1.0.1.tar.bz2"
  sha256 "b351168d4c161cb62b51489a41c592dd920fef19ae87d6c14cab24b38062dcd7"
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-fortress.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "5f7844c187ac1aed86060c35e263580074b96c7cf3f4927fb87f469ac7aadec3"
    sha256 cellar: :any, catalina: "589899659da22184db334ddb903fff1e9e705852e6dd288ab63e665ff48108b6"
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
    yaml_file = share/"ignition/ignition-fortress/gazebodistro/collection-fortress.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
