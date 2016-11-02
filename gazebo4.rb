class Gazebo4 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-4.1.3.tar.bz2"
  sha256 "5041b3f931f90c90b6163485b7074681f1a7a06dca9e3f271021a1d3b6777a53"
  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo_4.1", :using => :hg

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
  depends_on "dartsim/dart/dartsim" => [:optional, "core-only"]
  depends_on "ffmpeg" => :optional
  depends_on "gts" => :optional
  depends_on "player" => :optional
  depends_on "simbody" => :recommended

  conflicts_with "gazebo1", :because => "Differing version of the same formula"
  conflicts_with "gazebo2", :because => "Differing version of the same formula"
  conflicts_with "gazebo3", :because => "Differing version of the same formula"
  conflicts_with "gazebo5", :because => "Differing version of the same formula"
  conflicts_with "gazebo6", :because => "Differing version of the same formula"
  conflicts_with "gazebo7", :because => "Differing version of the same formula"
  conflicts_with "gazebo8", :because => "Differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Disable gdal dependency for now (see gazebo issue #1063)
    url "https://gist.githubusercontent.com/scpeters/9199351/raw/6c90b487def89bff54ad5ad0688110d806063aa0/disable_gdal.patch"
    sha256 "61f327b3373c5b5a12cec4de03c1111c74e03a03aee7b426ddd04b598901ddbf"
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
    system "#{bin}/gz", "sdf"
  end
end
