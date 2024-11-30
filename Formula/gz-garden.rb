class GzGarden < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-garden"
  url "https://osrf-distributions.s3.amazonaws.com/gz-garden/releases/gz-garden-1.0.0.tar.bz2"
  sha256 "438e2c55aaeb28f827bb48464c83f49d81ab3a3486b4453a2ad30f8fa5edf95d"
  license "Apache-2.0"
  revision 10

  head "https://github.com/gazebosim/gz-garden.git", branch: "main"

  deprecate! date: "2024-09-30", because: "is past end-of-life date"

  depends_on "cmake" => :build

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
  depends_on "pkgconf"
  depends_on "sdformat13"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_predicate share/"gz/gz-garden/gazebodistro/collection-garden.yaml", :exist?
  end
end
