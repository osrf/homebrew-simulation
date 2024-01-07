class IgnitionFortress < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-fortress"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fortress/releases/ignition-fortress-1.0.3.tar.bz2"
  sha256 "eedbfb01e18038756eb596fa8f1c8aa955ca2be029fe40bb842ffee4d4452323"
  license "Apache-2.0"
  revision 6
  version_scheme 1

  head "https://github.com/gazebosim/gz-fortress.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "8122588dd6d1b47e555c702260b35ed52f05e91d5836bd73656b27290137f904"
    sha256 cellar: :any, monterey: "bb24058dea1a0c46dbe8a37bcd59df9b0f8dc2f620d1b750d9ca9ec61b1725c5"
  end

  depends_on "cmake" => :build
  depends_on "python@3.11" => [:build, :test]

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

    # install vcstool so it can be used in the test
    venv = virtualenv_create(libexec, Formula["python@3.11"].opt_libexec/"bin/python")
    %w[PyYAML vcstool].each do |pkg|
      venv.pip_install pkg
    end
  end

  test do
    yaml_file = share/"ignition/ignition-fortress/gazebodistro/collection-fortress.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
