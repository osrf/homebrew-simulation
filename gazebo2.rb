require 'formula'

class Gazebo2 < Formula
  homepage 'http://gazebosim.org'
  url 'http://gazebosim.org/assets/distributions/gazebo-current-2.2.2.tar.bz2'
  sha1 '1bf5d66a402f0b1e8e43a62e4f13e9b4f7d727b7'
  head 'https://bitbucket.org/osrf/gazebo', :branch => 'gazebo_2.2', :using => :hg
  unstable 'https://bitbucket.org/osrf/gazebo', :branch => 'default', :using => :hg

  depends_on 'cmake'  => :build
  depends_on 'pkg-config' => :build

  depends_on 'boost'
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'libtar'
  depends_on 'ogre'
  depends_on 'protobuf'
  depends_on 'protobuf-c'
  depends_on 'qt'
  depends_on 'sdformat'
  depends_on 'tbb'
  depends_on 'tinyxml'

  depends_on 'bullet' => [:optional, 'shared', 'double-precision']
  depends_on 'dartsim/dart/dartsim' => [:optional, 'core-only']
  depends_on 'ffmpeg' => :optional
  depends_on 'player' => :optional
  depends_on 'simbody' => :optional
  # can't figure out how to specify optional gem dependency
  #depends_on 'ronn' => [:ruby, :optional]

  def patches
    patches = [
      'https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch',
    ]
    if build.unstable?
      patches << 'https://gist.githubusercontent.com/scpeters/9199351/raw/6c90b487def89bff54ad5ad0688110d806063aa0/disable_gdal.patch'
    end
    patches
  end

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"
    cmake_args << "-DFORCE_GRAPHIC_TESTS_COMPILATION:BOOL=True"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make install"
    end
  end
end
