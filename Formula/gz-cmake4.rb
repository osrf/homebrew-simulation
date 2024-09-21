class GzCmake4 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-4.0.0~pre1.tar.bz2"
  version "4.0.0-pre1"
  sha256 "7934b0b8091370adc7d0773b0829a586a87e4751a367b8687803ebde57407029"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, sonoma:   "9ddd25518db35e7d9ce475f8368783b0f495a9397aaaaa50f7dd8b673222fe7a"
    sha256 cellar: :any_skip_relocation, ventura:  "ebd81276f32466fba9a23d1de6e0b9acc309a2508f64a00087c34df6126c7f72"
    sha256 cellar: :any_skip_relocation, monterey: "2775187beaaf53e409da64a68112420924726dec4bc4ab8ed278205423b3026f"
  end

  depends_on "cmake"
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      project(gz-test VERSION 0.1.0)
      find_package(gz-cmake4 REQUIRED)
      gz_configure_project()
      gz_configure_build(QUIT_IF_BUILD_ERRORS)
    EOS
    %w[doc include src test].each do |dir|
      mkdir dir do
        touch "CMakeLists.txt"
      end
    end
    mkdir "build" do
      system "cmake", ".."
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
