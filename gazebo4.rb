require 'formula'

class Gazebo4 < Formula
  homepage 'http://gazebosim.org'
  url 'http://gazebosim.org/assets/distributions/gazebo-4.0.0.tar.bz2'
  sha1 '6388cbac9c3dd4364a6c13ac6685a7d9fa6e6d95'
  head 'https://bitbucket.org/osrf/gazebo', :branch => 'default', :using => :hg

  depends_on 'cmake'  => :build
  depends_on 'pkg-config' => :build

  depends_on 'boost'
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'libtar'
  depends_on 'ogre'
  depends_on 'osrf/simulation/protobuf'
  depends_on 'protobuf-c'
  depends_on 'qt'
  depends_on 'sdformat'
  depends_on 'tbb'
  depends_on 'tinyxml'

  depends_on 'bullet' => [:recommeded, 'shared', 'double-precision']
  depends_on 'dartsim/dart/dartsim' => [:optional, 'core-only']
  depends_on 'ffmpeg' => :optional
  depends_on 'player' => :optional
  depends_on 'simbody' => :recommended

  patch do
    # Fix build when homebrew python is installed
    url 'https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch'
    sha1 'eaa6f843ab1264810c0c0a81ff3c52232fd49d12'
  end

  patch do
    # Disable gdal dependency for now (see gazebo issue #1063)
    url 'https://gist.githubusercontent.com/scpeters/9199351/raw/6c90b487def89bff54ad5ad0688110d806063aa0/disable_gdal.patch'
    sha1 'fc258137ab82d2a6b922f46f345366e72e96c1b8'
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
