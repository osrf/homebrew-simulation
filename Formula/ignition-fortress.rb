class IgnitionFortress < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-fortress"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fortress/releases/ignition-fortress-1.0.0.tar.bz2"
  sha256 "0cce1b5676b32e8363efae4ab59cca0fcf4314b996977195737adb317530e735"
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-fortress.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "6f1a03d05ab8578be1a49b2442a8c6e18b290357dc07283875475ec4983ebc42"
    sha256 cellar: :any, catalina: "3b7c9091bac0c69aa41b5102ea9bcf49562bb6b83923b837ca4da5de01185d71"
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
    url "https://github.com/ignitionrobotics/ign-fortress/archive/04ec53d31ad5133a65ab8bcdcd0fdf7beb2e8ced.tar.gz"
    sha256 "98bb853cd84224e5f63584ab3220e0b9b779f0e466f44a04bd8fb2623fab0ba5"
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
