class IgnitionCmake < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "http://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-cmake/get/c82f9d30b12b9fc217eeb96c6c1016739c326dbf.tar.gz"
  version "0.1.0~20171003~c82f9d3"
  sha256 "1ade377912a62e82b5561e14cc1de4816bd558b5687206c7ecf6f9626cf18e2e"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-cmake/releases"
    cellar :any
    sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :high_sierra
    sha256 "023dad858a1521773636347a3ff1755f416e770d12581e6ff736f8b79dd342bd" => :sierra
    sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :el_capitan
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
