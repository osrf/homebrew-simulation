class IgnitionCmake1 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake1-1.1.0~pre3.tar.bz2"
  version "1.1.0~pre3"
  sha256 "65fe3fcc9b31ffa1e4f4398828335b8d63992cad59a5983cd205ae116ad6ff84"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-cmake/releases"
    cellar :any_skip_relocation
    sha256 "553279c9d31f104b61888e75a280a9191172ea5e130fbc8ce7cf6f3e9e734c59" => :el_capitan_or_later
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
