class GzCmake5 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-5.0.0.tar.bz2"
  sha256 "9853f9cd99b95324369cf9cb5ffef80c84e7526746fd2fe9b7b84a45362ffc88"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "33330dfe511bc5383c999f7327ac13e71b6b95ee6f54cad1f36ed41838cd1974"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "111394f97e1f216e611df2b6ef0b8f2b630e65c7fef1ef97a7778976cdd08ab2"
    sha256 cellar: :any_skip_relocation, sonoma:        "b3bffa838e3126237ab4d6f25dcdfe793f5122db03a5c0a26f7305263aa970b3"
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
