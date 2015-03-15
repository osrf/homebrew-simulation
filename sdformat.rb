require 'formula'

class Sdformat < Formula
  homepage 'http://sdformat.org'
  url 'http://gazebosim.org/distributions/sdformat/releases/sdformat-2.3.1.tar.bz2'
  sha1 '18a7dca5fb406106e8fc644d45c4feee923ef5e1'
  head 'https://bitbucket.org/osrf/sdformat', :branch => 'sdf_2.3', :using => :hg

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build

  depends_on 'boost'
  depends_on 'doxygen'
  depends_on 'ros/deps/urdfdom'
  depends_on 'ros/deps/urdfdom_headers'
  depends_on 'tinyxml'

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_BUILD_TYPE='Release'",
      "-DCMAKE_INSTALL_PREFIX='#{prefix}'",
      "-Wno-dev"
    ]
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
