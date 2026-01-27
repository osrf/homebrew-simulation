class GzCmake4 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-4.2.1.tar.bz2"
  sha256 "7a6cdb3b21afb711679f30fe43a427e285f57de6b8f93e948721fec2405b5f5d"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "6971403735984d53109d2b8f7067cce3066d43aab538fa2c92aacd416d1f1f0c"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "a04ec1c9e7d6447ac56622231abcd27a6f8c158723a75bb0d5eb3328e5c1fccb"
    sha256 cellar: :any_skip_relocation, sonoma:        "978b2b01128bf20f6e80c36ee1ea7f6f5085527b24267dd81df8030e139c4531"
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
