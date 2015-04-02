class Sdformat3 < Formula
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat3-prerelease-3.0.2.tar.bz2"
  sha256 "d7818125efb27d380c3be8dbf508065de6d0795c8cfcf68c564699f0989672af"
  version "3.0.2prerelease"
  head "https://bitbucket.org/osrf/sdformat", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ros/deps/urdfdom" => :optional
  depends_on "tinyxml"

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX='#{prefix}'",
      "-Wno-dev",
    ]
    cmake_args << "-DUSE_EXTERNAL_URDF:BOOL=True" if build.with? "urdfdom"
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "pkg-config", "--modversion", "sdformat"
  end
end
