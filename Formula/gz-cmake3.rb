class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.6.0.tar.bz2"
  sha256 "ec6c50bb30f89cfd07aff8450104ad31b2971d2ec1025eb7b042a74199a328bc"
  license "Apache-2.0"
  revision 1

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "45f46a8d98201f1c790fedb56b959b3a720fea4d5a7a81bf952eee291fa1ca7e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "c208640e5fd2d900b0164a66e3d423466ef75b4694e3d7eb54177602c3e5a2c4"
    sha256 cellar: :any_skip_relocation, sonoma:        "94f7e39e3cd5a08144a65e141005212e6b9afa6b1e50099800ad9d0019720494"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  patch do
    # Fix for warnings with cmake 4.4.0
    url "https://github.com/gazebosim/gz-cmake/commit/eb85f5f20d9358c65a0ec1afa0c391b3254a8e26.patch?full_index=1"
    sha256 "908c1f411deaec48ccf24545b8bfaa0671891d55531ffc345855edabebd39ccb"
  end

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
