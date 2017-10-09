class IgnitionCmake0 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake-0.1.0.tar.bz2"
  sha256 "9b79655b925d733333d944f36905c0ecd9971482c04e041feb5cef6184b16a72"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-cmake/releases"
    cellar :any_skip_relocation
    sha256 "9d8b7c6a1ffcfe1d023d200865c54b194f6e7d8047ed106c447baaaac2198d3c" => :el_capitan_or_later
  end

  depends_on "cmake" => :run

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS.undent
      cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
      find_package(ignition-cmake0 REQUIRED)
      ign_configure_project(test 0.1.0)
      ign_configure_build(QUIT_IF_BUILD_ERRORS)
      #ign_create_packages()
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
