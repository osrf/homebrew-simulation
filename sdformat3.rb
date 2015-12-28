class Sdformat3 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-3.6.0.tar.bz2"
  sha256 "c7ddf7958aaae2b143c713a44a4e83210f9753bce8f0dccbaf9cfc41293896cd"
  head "https://bitbucket.org/osrf/sdformat", :branch => "sdf3", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/sdformat/releases"
        sha256 "b050e80fdd6df5a43aff56d4bc6db6e9dc96517e7971da417fd3532ffac58b06" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "ignition-math2"
  depends_on "ros/deps/urdfdom" => :optional
  depends_on "tinyxml"

  def install
    ENV.m64

    cmake_args = std_cmake_args
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
