class IgnitionCmake0 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "http://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-cmake/get/ecc284a8d4c8.tar.gz"
  version "0.1.0~20171006~ecc284a"
  sha256 "4eba15c53553fb3f546db3b1e1db6e2c2f614a7918ae379fab9f697cef32846d"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-cmake/releases"
    cellar :any_skip_relocation
    sha256 "2b2342903e9fbb0c8243ac9a1b414316174f85afd1d7fd00624c96212c93cd1d" => :el_capitan_or_later
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
