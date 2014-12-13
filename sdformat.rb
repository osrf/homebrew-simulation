require 'formula'

class Sdformat < Formula
  homepage 'http://gazebosim.org/sdf.html'
  url 'http://gazebosim.org/assets/distributions/sdformat-2.1.0.tar.bz2'
  sha1 '39dbdab8cf5713873f4b02ccfb4f7e84a251dc9b'
  head 'https://bitbucket.org/osrf/sdformat', :branch => 'sdf_2.0', :using => :hg

  depends_on 'boost'
  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'ros/deps/urdfdom'
  depends_on 'ros/deps/urdfdom_headers'
  depends_on 'doxygen'
  depends_on 'tinyxml'

  def install
    ENV.m64

    cmake_args = [
      "-DUSE_EXTERNAL_URDF:BOOL=True",
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
