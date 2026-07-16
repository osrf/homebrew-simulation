class GzCmake5 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-5.1.1.tar.bz2"
  sha256 "d1ca0245cdcbb050ebd8ccfa67d0837b88d2a0ab7d9ceadbe4478c1f9d533006"
  license "Apache-2.0"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "1246138465bff451f4ffe515bde28c3a7f0b9eb5c957a0d35912227c6a1611a9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f422c17515ab57f0b98940192a0ba74c05019b17c79182df827560792cacfd06"
    sha256 cellar: :any_skip_relocation, sonoma:        "db4286b7329b2f1c494a17fe2d8c1ecd169e1b849dd5e4bd4c1a3e3e71378cbb"
  end

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake5"

  depends_on "cmake"
  depends_on "pkgconf"

  conflicts_with "gz-rotary-cmake", because: "both install gz-cmake"

  patch do
    # Fix for warnings with cmake 4.4.0
    url "https://github.com/gazebosim/gz-cmake/commit/2302ac12989d3a464247224a4b9465a28526c638.patch?full_index=1"
    sha256 "e6fc0b7f4e7869b2a64e91eabd292207e2a4c9086962d8e013f501a2b699b89e"
  end

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
      find_package(gz-cmake REQUIRED)
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
