class GzCmake5 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-5.0.2.tar.bz2"
  sha256 "dc1e79a3f98b29e4f032d590627bc991e477922bacbaf734f6d9003dbc6613f9"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "25c2a0981ce86866ed966446c5a447e4329616f96e29e81ce35251760a69227e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d7d1d8b10a8175c49912742a154ebdf9587fcd34acc0e209bbb628abb6a686e5"
    sha256 cellar: :any_skip_relocation, sonoma:        "3981cd4d7f941be007d02831b2347461e4c07bead18dc49ebafc77a19caae549"
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
