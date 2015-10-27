class Sdformat4 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://bitbucket.org/osrf/sdformat/get/e74d26c.tar.bz2"
  version "4.0.0-20151026-e74d26c"
  sha256 "9e92c88ded1d1353376bc5e3fd614c370a76da0f8dbfe7a34b278bca3a56fc82"
  head "https://bitbucket.org/osrf/sdformat", :branch => "default", :using => :hg

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
