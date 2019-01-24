class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake2-2.0.0~pre4.tar.bz2"
  version "2.0.0~pre4"
  sha256 "c984b29e0b3345e945e2f07023677405bd2f06aec52e10c94de8e8d6157aa1a6"

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "529bdfa04febe001cf6234fbf3831ce20db7cf068125588fe12b36ac189dae0c" => :mojave
    sha256 "10c7e07fad220fa88adbb52bd7d825715ce61a484ba7a0ce87e022231aa5a35a" => :high_sierra
    sha256 "8c82054d5a5891bfc76bee5a961ab3b3616960c0bd335d6edfb24e326350f542" => :sierra
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
