class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.7.0.tar.bz2"
  sha256 "12fc3ada2b137606aaf39e663872f06a864faa29ac00cc77f127c3ded462c442"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "e9565fb98fc48c17b26d7ec5f9a5ab93070e1d83903b964b875e9164af9d8f09"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "dd61d401a49ff69b0d9991eb3d312132183a700401f483252eed3e76e25a47eb"
  end

  deprecate! date: "2027-01-10", because: "freeimage is disabled"

  depends_on "cmake"
  depends_on "pkgconf"

  def install
    cmake_args = std_cmake_args

    # Disable doc target due to bug in doxygen 1.18
    # see https://github.com/osrf/homebrew-simulation/issues/3616
    cmake_args << "-DBUILD_DOCS=OFF"

    # Use build folder
    mkdir "build" do
      system "cmake", "-S", "..", "-B", ".", *cmake_args
      system "make", "install"
    end
  end

  def ci_cmake_args
    ["-DBUILDSYSTEM_TESTING=True", "-DBUILD_DOCS=OFF"]
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
