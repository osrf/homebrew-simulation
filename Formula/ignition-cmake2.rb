class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake2-2.0.0~pre3.tar.bz2"
  version "2.0.0~pre3"
  sha256 "20134ddeabd6e54cb4aad7ffd7a6b357746bd58ff6e41603ad69bd37a0d8559e"

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "f3535b0a730ec401e3c73344190c6970571a5d59870d38f1724f030970868ff2" => :mojave
    sha256 "243af0747cf9b3e8e03d9ff00a45fe6fefbc2ab7815758ad4d4e36d84c77f0c7" => :high_sierra
    sha256 "c4147bbe1852fc39e220d7308381e2ff1deabb534afceeaedbe02367b90dd778" => :sierra
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
