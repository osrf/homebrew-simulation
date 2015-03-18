require 'formula'

class Gazebo5 < Formula
  homepage 'http://gazebosim.org'
  url 'http://gazebosim.org/distributions/gazebo/releases/gazebo-5.0.1.tar.bz2'
  sha1 'f9102a34dd34c5c7ab1ceef09752d2316bfef25e'
  head 'https://bitbucket.org/osrf/gazebo', :branch => 'gazebo5', :using => :hg

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

  depends_on 'bullet' => [:recommended, 'shared', 'double-precision']
  depends_on 'dartsim/dart/dartsim' => [:optional, 'core-only']
  depends_on 'ffmpeg' => :optional
  depends_on 'gdal' => :optional
  depends_on 'gts' => :optional
  depends_on 'player' => :optional
  depends_on 'simbody' => :recommended

  patch do
    # Fix build when homebrew python is installed
    url 'https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch'
    sha1 'eaa6f843ab1264810c0c0a81ff3c52232fd49d12'
  end

  patch do
    # Fix gdal support (see gazebo issue #1063)
    url 'https://bitbucket.org/osrf/gazebo/commits/bc1349163e8c2988769e8e54297e47506205f51b/raw/'
    sha1 'a371ebb2e83cef433e6985ce7207eb561eb25fbd'
  end

  def install
    ENV.m64

    cmake_args = std_cmake_args.select { |arg| arg.match(/CMAKE_BUILD_TYPE/).nil? }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"
    cmake_args << "-DFORCE_GRAPHIC_TESTS_COMPILATION:BOOL=True"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make install"
    end
  end
end
