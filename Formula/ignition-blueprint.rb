class IgnitionBlueprint < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-blueprint"
  url "https://osrf-distributions.s3.amazonaws.com/ign-blueprint/releases/ignition-blueprint-1.0.0.tar.bz2"
  url "https://github.com/ignitionrobotics/ign-blueprint/archive/a3f44f4ab45633e807b1a0402d6952b95c6b2d6f.tar.gz"
  version "1.0.1~0~20201207~a3f44f"
  sha256 "190fe8c427adfe300da62b772ef9fe1bf118f38acf81efd6cdb7672bbc67c304"

  head "https://github.com/ignitionrobotics/ign-blueprint", branch: "main"

  deprecate! date: "2020-12-31", because: "is past end-of-life date"
  disable! date: "2021-01-31", because: "is past end-of-life date"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "454a2f24373107bf43de3f449c06a2b99456b0dfc911891919378e9306d1bb99" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools3"
  depends_on "ignition-gazebo2"
  depends_on "ignition-gui2"
  depends_on "ignition-launch1"
  depends_on "ignition-math6"
  depends_on "ignition-msgs4"
  depends_on "ignition-physics1"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering2"
  depends_on "ignition-sensors2"
  depends_on "ignition-tools"
  depends_on "ignition-transport7"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "python@3.9"
  depends_on "sdformat8"

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
    yaml_file = share/"ignition/ignition-blueprint/gazebodistro/collection-blueprint.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
