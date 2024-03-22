class GzIonic < Formula
  include Language::Python::Virtualenv

  desc "Collection of gazebo simulation software"
  homepage "https://github.com/gazebosim/gz-ionic"
  url "https://github.com/gazebosim/gz-ionic.git", branch: "main"
  version "0.999.999-0-20231016"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-ionic.git", branch: "main"

  depends_on "cmake" => :build

  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-fuel-tools10"
  depends_on "gz-gui9"
  depends_on "gz-launch8"
  depends_on "gz-math8"
  depends_on "gz-msgs11"
  depends_on "gz-physics8"
  depends_on "gz-plugin3"
  depends_on "gz-rendering9"
  depends_on "gz-sensors9"
  depends_on "gz-sim9"
  depends_on "gz-tools2"
  depends_on "gz-transport14"
  depends_on "gz-utils3"
  depends_on "pkg-config"
  depends_on "sdformat15"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_predicate share/"gz/gz-ionic/release_notes.md", :exist?
  end
end
