class Gazebo4 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-4.1.3.tar.bz2"
  sha256 "5041b3f931f90c90b6163485b7074681f1a7a06dca9e3f271021a1d3b6777a53"
  license "Apache-2.0"
  head "https://github.com/osrf/gazebo.git", branch: "gazebo_4.1"

  deprecate! because: "is past end-of-life date", date: "2016-01-25"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "protobuf-c" => :build

  depends_on "boost"
  depends_on "bullet"
  depends_on "cartr/qt4/qt@4"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "sdformat"
  depends_on "simbody"
  depends_on "tbb"
  depends_on "tinyxml"

  conflicts_with "gazebo2", because: "differing version of the same formula"
  conflicts_with "gazebo3", because: "differing version of the same formula"
  conflicts_with "gazebo5", because: "differing version of the same formula"
  conflicts_with "gazebo6", because: "differing version of the same formula"
  conflicts_with "gazebo7", because: "differing version of the same formula"
  conflicts_with "gazebo8", because: "differing version of the same formula"

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
    url "https://github.com/osrf/gazebo/commit/5f533662e72cf63c18f122a21cdc61599238d4c5.patch?full_index=1"
    sha256 "43453d5c7b97dc55ef88797dd488b7a7111de72521a2cdd44f8d68188e2db7ee"
  end

  patch do
    # Fix for compatibility with bullet 2.83
    url "https://gist.githubusercontent.com/scpeters/ef860211b6536a3d7a20/raw/b123b096c242b582de0ef93ea2acb77975250b01/gistfile1.diff"
    sha256 "342f5f713049722da2aaa102557c136a627067831b6d4eadabfaece297f8fa31"
  end

  def install
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
