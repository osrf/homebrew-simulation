class GzCmake4 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-4.3.0.tar.bz2"
  sha256 "11ff8af2611998e0cd1b9b219b849bb76538ce0bdf4a502e5c7ecb95c735ac69"
  license "Apache-2.0"
  revision 1

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "f2454bc11c4646c35f5b74060f7868a64076f69da40758ef04e0b6f075d63659"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "4a78338f1f236c06e145faacb1563ac5770f5426cc79897b1e66ed2715b730bb"
    sha256 cellar: :any_skip_relocation, sonoma:        "2d846242fa829e27c190c346f990ea12837ca9b44bb38cdc4d9175f5da57bb9c"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  patch do
    # Fix for warnings with cmake 4.4.0
    url "https://github.com/gazebosim/gz-cmake/commit/6c84857c8225a16f2b7af7540b30e5ebb85b505e.patch?full_index=1"
    sha256 "2aad36e1cfdcdfde4668468d21c23fab00d5b361fd6a5723ec9639421c017424"
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
