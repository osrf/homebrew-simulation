class IgnitionBlueprint < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/ignitionrobotics/ign-blueprint"
  url "https://osrf-distributions.s3.amazonaws.com/ign-blueprint/releases/ignition-blueprint-1.0.0.tar.bz2"
  url "https://osrf-distributions.s3.amazonaws.com/ign-blueprint/releases/ignition-blueprint-1.1.0.tar.bz2"
  sha256 "51e224efc51ce5ff7ef164883a5b7428e169409386900b82f7ef6b84b611d7aa"

  head "https://github.com/ignitionrobotics/ign-blueprint.git", branch: "main"

  disable! date: "2021-01-31", because: "is past end-of-life date"

  deprecate! date: "2020-12-31", because: "is past end-of-life date"

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
