class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.3.1.tar.bz2"
  sha256 "3582ab3c6ef7333e23e7e26b0c89e76d8f8f65a219504023bc7506e5377a9e83"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, monterey: "0dd25b569a71b211d9f0636e89164e51d5669419e72c1d0ecb6c95de73a851c0"
    sha256 cellar: :any_skip_relocation, big_sur:  "24a1c55e0e0f9dc3bcb68be7b16feebf6442d1d709a12a254e39285ef84914f6"
  end

  depends_on "cmake"
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

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
