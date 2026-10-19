class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.6.0.tar.bz2"
  sha256 "ec6c50bb30f89cfd07aff8450104ad31b2971d2ec1025eb7b042a74199a328bc"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "8690448a49e7b7ff59e371c5a9bfed7b5c886a673250aee8cb10620d9e777c28"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9ed1677120001d6a3511cf91500cb90933d39c0b5e9a7c3fc60064fb4158ccc1"
  end

  deprecate! date: "2027-01-10", because: "freeimage is disabled"

  depends_on "cmake"
  depends_on "pkgconf"

  patch do
    # Fix for warnings with cmake 4.4.0
    url "https://github.com/gazebosim/gz-cmake/commit/eb85f5f20d9358c65a0ec1afa0c391b3254a8e26.patch?full_index=1"
    sha256 "908c1f411deaec48ccf24545b8bfaa0671891d55531ffc345855edabebd39ccb"
  end

  patch do
    # Fix for BUILD_DOCS=OFF
    url "https://github.com/gazebosim/gz-cmake/commit/a11766eec8093df23be53a003e26362874a73914.patch?full_index=1"
    sha256 "bc7596bfb61a0bc5e9e0a9ede9da2bd7a9500982d1bea32bc1bc6ecf60d7d0e0"
  end

  def install
    cmake_args = std_cmake_args

    # Use build folder
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
      system "cmake", "-S", "..", "-B", "."
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
