class GzGarden < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-garden"
  url "https://osrf-distributions.s3.amazonaws.com/gz-garden/releases/gz-garden-1.0.0.tar.bz2"
  sha256 "438e2c55aaeb28f827bb48464c83f49d81ab3a3486b4453a2ad30f8fa5edf95d"
  license "Apache-2.0"
  revision 8

  head "https://github.com/gazebosim/gz-garden.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "122fe74ea3aa52a81b7ae9aaf53040b56768317bd88605064aa339d6519c7d82"
    sha256 cellar: :any, monterey: "5f76fb92892aeb4eb51f49737ef3bec775c664a0945b6d98fcd2a0f4f32f656c"
  end

  depends_on "cmake" => :build
  depends_on "python@3.11" => [:build, :test]

  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-fuel-tools8"
  depends_on "gz-gui7"
  depends_on "gz-launch6"
  depends_on "gz-math7"
  depends_on "gz-msgs9"
  depends_on "gz-physics6"
  depends_on "gz-plugin2"
  depends_on "gz-rendering7"
  depends_on "gz-sensors7"
  depends_on "gz-sim7"
  depends_on "gz-tools2"
  depends_on "gz-transport12"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat13"

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/64/c2/b80047c7ac2478f9501676c988a5411ed5572f35d1beff9cae07d321512c/PyYAML-5.3.1.tar.gz"
    sha256 "b8eac752c5e14d3eca0e6dd9199cd627518cb5ec06add0de9d32baeee6fe645d"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    # install vcstool for use in the test
    venv = virtualenv_create(libexec, Formula["python@3.11"].opt_libexec/"bin/python")
    %w[PyYAML vcstool].each do |pkg|
      venv.pip_install pkg
    end
  end

  test do
    yaml_file = share/"gz/gz-garden/gazebodistro/collection-garden.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
