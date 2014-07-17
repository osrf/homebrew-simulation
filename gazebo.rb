require 'formula'

class Gazebo < Formula
  homepage 'http://gazebosim.org'
  url 'http://gazebosim.org/assets/distributions/gazebo-1.9.5.tar.bz2'
  sha1 '1bf5d66a402f0b1e8e43a62e4f13e9b4f7d727b7'
  head 'https://bitbucket.org/osrf/gazebo', :branch => 'gazebo_1.9', :using => :hg

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

  depends_on 'bullet' => [:optional, 'shared', 'double-precision']
  depends_on 'ffmpeg' => :optional
  depends_on 'player' => :optional

  patch do
    # Fix build when homebrew python is installed
    url 'https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch'
    sha1 'eaa6f843ab1264810c0c0a81ff3c52232fd49d12'
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
