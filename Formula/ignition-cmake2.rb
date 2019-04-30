class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake2-2.1.0~pre1.tar.bz2"
  version "2.1.0~pre1"
  sha256 "e5c72d31574f875f9c43553bf85f91555e74889beea5e04a2364805e72f36f2e"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "0dc5414ee4b2904805335a54d4628c74f8fcaadc7a68ef36912931cc63006912" => :mojave
    sha256 "70134b089036c26760cd83fc5c696a54f04cb21deaa51e23560e9fb4f2cf56b8" => :high_sierra
    sha256 "2bf957c516587e42a0fe0dd1d88619376bc33b1b2b8d71623e11a21630bbafd6" => :sierra
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
