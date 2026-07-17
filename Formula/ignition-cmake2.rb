class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/ignition-cmake-2.19.0.tar.bz2"
  sha256 "032f4172919474c36c209dc6f28513d9ac68cc5a801eb86123bfc03c7e88ae75"
  license "Apache-2.0"
  revision 1

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "75942e91db8426becce21cb6cd23e2c16765e062fb3e5496bef6f2fc7707934a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "b1e56c95b37c0c5837e5e31e4606dc94752d8a6601a62b49888ea8b05493b34d"
    sha256 cellar: :any_skip_relocation, sonoma:        "2421641f7a3bb4c3325fc489617d5d1e1f629f026c9e35994492b639f34e11ee"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  patch do
    # Fix for warnings with cmake 4.4.0
    url "https://github.com/gazebosim/gz-cmake/commit/317d056ec2bb3c454fdcaf2ca6063c3cf88c7cc9.patch?full_index=1"
    sha256 "4ef376c321959b92fae467d66995148020e4fa5825134c2595b8ff8efde5e79c"
  end

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
