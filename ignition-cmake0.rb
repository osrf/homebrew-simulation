class IgnitionCmake0 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake-0.2.0~pre1.tar.bz2"
  version "0.2.0~pre1"
  sha256 "2ffc71dd152006ea859892043cdb4ea481afc5b0e1a8aebfb8b595bc405c371a"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-cmake/releases"
    cellar :any_skip_relocation
    sha256 "2d97329e058e0745cc68c69a4c3828535ad861419a3ee7679eb43b4bf4bfae5a" => :el_capitan_or_later
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
