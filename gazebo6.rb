class Gazebo6 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-6.6.0.tar.bz2"
  sha256 "0097f694cbcaad8a4508da78472cdf9ccf4cdf7ab20f153beb151b48d7252e96"
  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo6", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    revision 1
    sha256 "e2d2a5dcd9c05f96df1899ea1dda12f7b3a4ea13f4bd3d7cb246e2c1ed20303b" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "ignition-math2"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt"
  depends_on "sdformat3"
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
    # Fix build with ffmpeg3
    url "https://bitbucket.org/osrf/gazebo/commits/f8a81c872d1c16f99f48be8b306dfefa64a96173/raw"
    sha256 "27876e797dd0b91f3eff026dcc79137ed53dc00d9e170ef3eb9e4e6941bc0ded"
  end

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "gz", "sdf"
  end
end
