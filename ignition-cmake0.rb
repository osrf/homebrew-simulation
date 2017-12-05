class IgnitionCmake0 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake-0.2.0.tar.bz2"
  sha256 "b21ba08a2b144125029e5d9a531ed2605ee577926515ca2d650c25943084152e"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-cmake/releases"
    cellar :any_skip_relocation
    sha256 "59a7e6d6fb4c1a5405c758b37d4268cf27d43a436a88dc2388bbdae5471758ae" => :el_capitan_or_later
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
