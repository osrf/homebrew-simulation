class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/ignition-cmake-2.17.3~pre1.tar.bz2"
  version "2.17.3-pre1"
  sha256 "a4a221679d864b975899b87e05b163bbe74247961fc57710485b9681f9edd255"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, sonoma:  "ea9ba6004ab3ed43af20b38f81364e272c2a2dc3127da8d1fa76103a20725f74"
    sha256 cellar: :any_skip_relocation, ventura: "f1a5263b8d7bcfb8eaf3ebe90b74915d2dccf57909a4af7c7716a1532cb1eae4"
  end

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
