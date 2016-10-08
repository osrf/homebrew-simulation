class Sdformat < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-2.3.2.tar.bz2"
  sha256 "f1e6e39f1240c6a1732ed3fd26fd70e2bf865aed15fc4b0a24c0f76562eac0ae"
  revision 1

  head "https://bitbucket.org/osrf/sdformat", :branch => "sdf_2.3", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/sdformat/releases"
    sha256 "d0d0a935f46adc4403cbfdb9cd96fa3cd77e3fdd0dafe355e911e5db92602705" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "pkg-config" => :run
  depends_on "ros/deps/urdfdom" => :optional
  depends_on "tinyxml"

  conflicts_with "sdformat3", :because => "Differing version of the same formula"
  conflicts_with "sdformat4", :because => "Differing version of the same formula"

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
