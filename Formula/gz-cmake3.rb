class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.5.5.tar.bz2"
  sha256 "bc7b14d07e47e1783002b567e1a4267624fd09b89993101726a0ddc561b5d159"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "00b011d9b59df8d8a9e329b196f2f80b4bf25ef29a478d9e8d6c6c5e48bbe380"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d397ace2e8797c364e6c31d3965920bc588f8dcf77ad8f22789663ac8eaa0b91"
    sha256 cellar: :any_skip_relocation, sonoma:        "db13764b26729818b3d2018bedbac3bdc74b887a66b8570fe75de07754139a28"
    sha256 cellar: :any_skip_relocation, ventura:       "9e17ba417e9a25b7e11c9f5e3e98b1ff4535a05b7a93502fc0b8c9e1d13222ab"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  def install
    cmake_args = std_cmake_args

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
      project(gz-test VERSION 0.1.0)
      find_package(gz-cmake3 REQUIRED)
      gz_configure_project()
      gz_configure_build(QUIT_IF_BUILD_ERRORS)
    EOS
    # Create necessary cmake files
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
