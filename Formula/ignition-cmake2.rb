class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake2-2.0.0~pre3.tar.bz2"
  version "2.0.0~pre3"
  sha256 "20134ddeabd6e54cb4aad7ffd7a6b357746bd58ff6e41603ad69bd37a0d8559e"

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "9fd0b2cd27ed9cea32dbb689befc72b56d467c3287e05be765ef05116f6f13d0" => :mojave
    sha256 "abbab0f4fbebb15492e602c5d04789cc5ced3e3dbccef08a5bfc4954a95ee8c2" => :high_sierra
    sha256 "859628201a9f622600edca59d0b5b812ad75102823ef9bdd5faca0dbb0e81d28" => :sierra
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
  end
end
