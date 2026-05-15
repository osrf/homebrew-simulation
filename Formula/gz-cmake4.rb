class GzCmake4 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-4.3.0.tar.bz2"
  sha256 "11ff8af2611998e0cd1b9b219b849bb76538ce0bdf4a502e5c7ecb95c735ac69"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5e810901fd4c8cc4b49f3d784c8f03239de34cddb0df526f1a9637b7b0458937"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "938a17a19323f9dcd9b8c52ff7945b1593fe32d293b4dd9f447f84d11d6e6553"
    sha256 cellar: :any_skip_relocation, sonoma:        "d811c2d6ff9f792860aebd389631db7024b3430549d7229c444a1ae9d4f6563a"
  end

  depends_on "cmake"
  depends_on "pkgconf"

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
