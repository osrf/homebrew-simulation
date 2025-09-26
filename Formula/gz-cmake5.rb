class GzCmake5 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-5.0.0.tar.bz2"
  sha256 "9853f9cd99b95324369cf9cb5ffef80c84e7526746fd2fe9b7b84a45362ffc88"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "9c8bcb0ba42aaefdf44badcefe5b7b9a802acb13f22e507b2d0d0c6e800b9821"
    sha256 cellar: :any_skip_relocation, sonoma:       "65cc1bacd528d84e72702a9ea96b682b6d3d07075e906550456d214461454941"
    sha256 cellar: :any_skip_relocation, ventura:      "58d1a7d82cbd191cd309f79c0983ee173ebb873f5a6c7e7ac42fbe077428760b"
  end

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake5"

  depends_on "cmake"
  depends_on "pkgconf"

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
