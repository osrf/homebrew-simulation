class GzHarmonic < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-harmonic"
  url "https://osrf-distributions.s3.amazonaws.com/gz-harmonic/releases/gz-harmonic-1.0.0.tar.bz2"
  sha256 "50a60b775c7b9f21351667ec9912a3049129c49f89bfd1658af7381431e9d190"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-harmonic.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "python@3.11" => [:build, :test]

  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-fuel-tools9"
  depends_on "gz-gui8"
  depends_on "gz-launch7"
  depends_on "gz-math7"
  depends_on "gz-msgs10"
  depends_on "gz-physics7"
  depends_on "gz-plugin2"
  depends_on "gz-rendering8"
  depends_on "gz-sensors8"
  depends_on "gz-sim8"
  depends_on "gz-tools2"
  depends_on "gz-transport13"
  depends_on "gz-utils2"
  depends_on "pkg-config"
  depends_on "sdformat14"

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/64/c2/b80047c7ac2478f9501676c988a5411ed5572f35d1beff9cae07d321512c/PyYAML-5.3.1.tar.gz"
    sha256 "b8eac752c5e14d3eca0e6dd9199cd627518cb5ec06add0de9d32baeee6fe645d"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end

    venv = virtualenv_create(libexec, Formula["python@3.11"].opt_libexec/"bin/python")
    %w[PyYAML vcstool].each do |pkg|
      venv.pip_install pkg
    end
  end

  test do
    yaml_file = share/"gz/gz-harmonic/gazebodistro/collection-harmonic.yaml"
    system libexec/"bin/vcs", "validate", "--input", yaml_file
  end
end
