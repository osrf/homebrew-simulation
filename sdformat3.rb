class Sdformat3 < Formula
  homepage 'http://sdformat.org'
  url 'http://gazebosim.org/distributions/sdformat/releases/sdformat3-prerelease-3.0.1.tar.bz2'
  sha256 'd1ad746b9c49f45d1ec463e7cce638e1fb0de2c87b8f04a2f8e2bf23bd3e2e21'
  version '3.0.1prerelease'
  head 'https://bitbucket.org/osrf/sdformat', :branch => 'default', :using => :hg

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
      system "make", "install"
    end
  end

  test do
    system "pkg-config --modversion sdformat"
  end
end
