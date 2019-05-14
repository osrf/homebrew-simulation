class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake2-2.1.0~pre2.tar.bz2"
  version "2.1.0~pre2"
  sha256 "02daa17d8d89c2098ee5cda2ea99f5fc99ea07e425bebc6adccb7fd961f54174"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "559921245e357e9d7df048023733da95b5d6d0f5ae4a775c78872d923aaa0c18" => :mojave
    sha256 "00e2c9725e518f5c69e6c8d741832eaa4058613030978b8b3d7a1e38dee1970c" => :high_sierra
    sha256 "2b25608907d108341164b2cf6173d5b7553f7a8d56a760dd9b5f875d067a1016" => :sierra
  end

  depends_on "cmake"
  depends_on "pkg-config"

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
