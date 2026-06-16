class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/ignition-cmake-2.19.0.tar.bz2"
  sha256 "032f4172919474c36c209dc6f28513d9ac68cc5a801eb86123bfc03c7e88ae75"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "7a1cf71c683c9a92f211ec620c172ab1458185392fce41cf88fc2550e54fdc93"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "68558e278c1ea762409edd638368515143f4021bf3a4f66a120174c752beb5de"
    sha256 cellar: :any_skip_relocation, sonoma:        "304d34804ccc19aff414e88eb0f5585f777a7a2b490672181c169d33ad96885a"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  def install
    cmake_args = std_cmake_args

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
      project(ignition-test VERSION 0.1.0)
      find_package(ignition-cmake2 REQUIRED)
      ign_configure_project()
      ign_configure_build(QUIT_IF_BUILD_ERRORS)
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
