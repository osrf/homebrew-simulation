class Gazebo5 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-5.2.1.tar.bz2"
  sha256 "a59730b31306c2d1645926a13b067eab7070acf9b85a9e1596db54a108edc483"
  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo5", :using => :hg

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt"
  depends_on "sdformat"
  depends_on "tbb"
  depends_on "tinyxml"

  depends_on "bullet" => [:recommended, "with-shared", "with-double-precision"]
  depends_on "dartsim/dart/dartsim4" => [:optional, "core-only"]
  depends_on "ffmpeg" => :optional
  depends_on "gdal" => :optional
  depends_on "gts" => :optional
  depends_on "player" => :optional
  depends_on "simbody" => :recommended

  patch do
    # Fix build when homebrew python is installed
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Fix for compatibility with boost 1.58
    url "https://bitbucket.org/osrf/gazebo/commits/91f6f3c59f40af34855548c37857955d08fd1368/raw/"
    sha256 "1a8b232be58f36bf5fa0129169f4d4d40d72624b460735457c781ba3e02c7900"
  end

  patch do
    # Fix for compatibility with bullet 2.83
    url "https://gist.githubusercontent.com/scpeters/ef860211b6536a3d7a20/raw/b123b096c242b582de0ef93ea2acb77975250b01/gistfile1.diff"
    sha256 "342f5f713049722da2aaa102557c136a627067831b6d4eadabfaece297f8fa31"
  end

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"
    cmake_args << "-DFORCE_GRAPHIC_TESTS_COMPILATION:BOOL=True"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "gzserver", "--iters", "1"
  end
end
