class IgnitionCmake1 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake1-1.1.0.tar.bz2"
  sha256 "1d9cad25b61774e0cb131fa244cc09b082166c2644b6aeaaa1f20d0d060cc30c"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "c35ac26d527e897f0a60bfe3cb41ddb8c9a05283d38d964a3254f8020b3b2d4b" => :mojave
    sha256 "7527124388711be4f75b4f927629c55f1b32ae64ef7063082d4fbdc6e2cd7b62" => :high_sierra
    sha256 "10cdf432ef40bbcdaee901763a457467710d3007bca99250fda5ac49cbd0bfae" => :sierra
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
      find_package(ignition-cmake1 REQUIRED)
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
