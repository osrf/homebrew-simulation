require 'formula'

class Sdformat < Formula
  homepage 'http://gazebosim.org/sdf.html'
  url 'http://gazebosim.org/assets/distributions/sdformat2-2.0.1.tar.bz2'
  sha1 'b11a1ce82a6fa9a6c87103618e40f30fe62b686a'
  head 'https://bitbucket.org/osrf/sdformat', :branch => 'sdf_2.0', :using => :hg

  depends_on 'boost'
  depends_on 'cmake' => :build
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
