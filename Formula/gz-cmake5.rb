class GzCmake5 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-5.2.0.tar.bz2"
  sha256 "38206aaf5dcf733f4a5bb081eb3fc027c1620def755aa046ebc8efb158c65291"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "a036e20ff0165e602abb738421259412fda55ccc30e7a5928a25c54b7d220fbc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "abd1c185b463778ffb3c5eb151a8a72e95d1e39fe57c0d145a3adaad1bd36b5e"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  conflicts_with "gz-rotary-cmake", because: "both install gz-cmake"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

    # Use a build folder
    mkdir "build" do
      system "cmake", "-S", "..", "-B", ".", *cmake_args
      system "make", "install"
    end
  end

  def ci_cmake_args
    ["-DBUILDSYSTEM_TESTING=True"]
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
      system "cmake", "-S", "..", "-B", "."
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
