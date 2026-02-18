class GzCmake5 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-5.0.2.tar.bz2"
  sha256 "dc1e79a3f98b29e4f032d590627bc991e477922bacbaf734f6d9003dbc6613f9"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "722700317a5d023df894a7efdd514b0b05b2607ed8ab04ca79898c717011eb2a"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "6a8ca230a50e4000651c52078699f439e94309539a50b3fb13b289fb336595f8"
    sha256 cellar: :any_skip_relocation, sonoma:        "d32ace00ee271f531eed88b9569d60a271497102c90c0a2ff47f1e403528ed3d"
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
