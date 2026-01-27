class GzCmake4 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-4.2.1.tar.bz2"
  sha256 "7a6cdb3b21afb711679f30fe43a427e285f57de6b8f93e948721fec2405b5f5d"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5726e1b734b659cb62475c3b2a58f162a89f45e92334df821ac0263a594363f0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "9a5f35d977bed3779f9d073a29609d3e2122c6618800ef1d0d3dcd11cc801524"
    sha256 cellar: :any_skip_relocation, sonoma:        "eb9861dd42a5137c9d4cc58777b1521c84e12d01e92e7df685ff918937c1ebe2"
    sha256 cellar: :any_skip_relocation, ventura:       "70891eec4fdbab5366f1a3a160a282fe6abcfc86c0c570f141470165e414d751"
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
