class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.4.1.tar.bz2"
  sha256 "59f7b58487a38406302c208f149401ce36b1f19d63d0b0a593b5e082af303f52"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, ventura:  "a3504208c227a394388e387a4357470fe6a4d69417c604384dfad852bb58411f"
    sha256 cellar: :any_skip_relocation, monterey: "adbbbceb7ab6600b46ddb1d9c15d54a735c65ae3a6531789d90c972302dbf344"
    sha256 cellar: :any_skip_relocation, big_sur:  "67d08d44776e17e7f227c8463b5b6a652711766012307ea21ec9da23968e3697"
  end

  depends_on "cmake"
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

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
