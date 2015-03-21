require 'formula'

class Sdformat < Formula
  homepage 'http://sdformat.org'
  url 'http://gazebosim.org/distributions/sdformat/releases/sdformat-2.3.2.tar.bz2'
  sha1 '9f8d1996a61d40d618b532eff5c6d2c7f7b04ffa'
  head 'https://bitbucket.org/osrf/sdformat', :branch => 'sdf_2.3', :using => :hg

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build

  depends_on 'boost'
  depends_on 'doxygen'
  depends_on 'ros/deps/urdfdom' => :optional
  depends_on 'tinyxml'

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_BUILD_TYPE='Release'",
      "-DCMAKE_INSTALL_PREFIX='#{prefix}'",
      "-Wno-dev"
    ]
    cmake_args << "-DUSE_EXTERNAL_URDF:BOOL=True" if build.with? 'urdfdom'
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make install"
    end
  end

  test do
    system "pkg-config --modversion sdformat"
  end
end
