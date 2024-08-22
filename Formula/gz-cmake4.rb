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
    sha256 cellar: :any_skip_relocation, ventura:  "733000e450c4d2d7e792e123e9cc22ce00084f86aa8c000959cb37ce81256af4"
    sha256 cellar: :any_skip_relocation, monterey: "a97eb561263676c96771d982f9d41d345f5612fe50846a72d0626ba0c8ece1de"
  end

  depends_on "cmake"
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

    # Use build folder
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
