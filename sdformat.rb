require 'formula'

class Sdformat < Formula
  homepage 'http://gazebosim.org/sdf.html'
  url 'http://gazebosim.org/assets/distributions/sdformat-1.4.0.tar.bz2'
  sha1 '5e4a79ee29792b7be41b2db557dc6260fa2909e0'

  depends_on 'boost'
  depends_on 'cmake' => :build
  depends_on 'doxygen'
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
