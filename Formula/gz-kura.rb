class GzKura < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-kura"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-kura.git", branch: "main"

  depends_on "cmake" => :build

  depends_on "gz-cmake6"
  depends_on "gz-common8"
  depends_on "gz-fuel-tools12"
  depends_on "gz-gui11"
  depends_on "gz-launch10"
  depends_on "gz-math10"
  depends_on "gz-msgs13"
  depends_on "gz-physics10"
  depends_on "gz-plugin5"
  depends_on "gz-rendering11"
  depends_on "gz-sensors11"
  depends_on "gz-sim11"
  depends_on "gz-tools4"
  depends_on "gz-transport16"
  depends_on "gz-utils5"
  depends_on "pkgconf"
  depends_on "sdformat17"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_path_exists share/"gz/gz-kura/release_notes.md"
  end
end
