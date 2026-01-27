class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/ignition-cmake-2.17.3.tar.bz2"
  sha256 "8743d3f0149b5f16c7c95e5b66934475eff698ac5ee9af52a469adcd56085fb9"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c21f94c7c14537acd2c4d15115505da7a095737db4e25e9afe0dcef69ca82939"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "91d04c5c86c128c5a706dbf3b9242c799def31e08852f436c43b1296bc7de5ad"
    sha256 cellar: :any_skip_relocation, sonoma:        "f44d5c93418f1781c9cfe80139af9dac66b027bd2491e162bb40a27a71206f6b"
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
