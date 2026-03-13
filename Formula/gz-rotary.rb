class GzRotary < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-rotary"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rotary.git", branch: "main"

  depends_on "cmake" => :build

  depends_on "gz-rotary-cmake"
  depends_on "gz-rotary-common"
  depends_on "gz-rotary-fuel-tools"
  depends_on "gz-rotary-gui"
  depends_on "gz-rotary-math"
  depends_on "gz-rotary-msgs"
  depends_on "gz-rotary-physics"
  depends_on "gz-rotary-plugin"
  depends_on "gz-rotary-rendering"
  depends_on "gz-rotary-sdformat"
  depends_on "gz-rotary-sensors"
  depends_on "gz-rotary-tools"
  depends_on "gz-rotary-transport"
  depends_on "gz-rotary-utils"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_path_exists share/"gz/gz-rotary/release_notes.md"
  end
end
