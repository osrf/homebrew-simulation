class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.5.6.tar.bz2"
  sha256 "47a9104aa447ca2a307c81b3cc88314fa40db005c0a5881417412ff7e98368e8"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "3c891b773ff8e95d57a4d8cba77fe77cf66d725957eb6f3bf3b1ea6f02dfda39"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b159cc8169ad41cd9c4471b5611fdd9447a82b30e13e8c70b8dc2d3b65a6da73"
    sha256 cellar: :any_skip_relocation, sonoma:        "7789962ec4814892b2a37c4763fc0540917785936e0ef1487d440a0536e8b977"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  def install
    cmake_args = std_cmake_args

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
    # Create necessary cmake files
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
