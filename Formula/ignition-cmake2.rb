class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake2-2.5.0.tar.bz2"
  sha256 "b5ea81835ea398b378edb818083f9dfc08441fadb721e37fc722d7faa9bd63b2"
  license "Apache-2.0"
  revision 2

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "81d46dfd407bf74609a2f305d07ff1e7d12087620f2618259489d4bbbec043d8" => :mojave
    sha256 "42dcfa0997f00db2ea5ed3f5799cd75f85c4df0705a8a2de708b2669a1ace055" => :high_sierra
  end

  depends_on "cmake"
  depends_on "pkg-config"

  patch do
    # Fix for finding ogre2 Overlay library
    url "https://github.com/ignitionrobotics/ign-cmake/commit/6a646e9201d84d7945b6aad4c12b0fa43d6af6f0.patch?full_index=1"
    sha256 "893e4174b470e67f9ff0a41ac20d7642d79e00f14581355ec418098d995337b1"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
    system "make", "install"
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
