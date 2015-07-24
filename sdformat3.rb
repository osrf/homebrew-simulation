class Sdformat3 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "http://gazebosim.org/distributions/sdformat/releases/sdformat-3.0.0.tar.bz2"
  sha256 "4a743b64db59c5d52d77c1f3b9a74781dd20a0777d37e36273585d2b45207e74"
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
