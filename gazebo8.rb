class Gazebo8 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://bitbucket.org/osrf/gazebo/get/d60939b4f3d4.tar.gz"
  version "8.0.0-20170104-d60939b4f3d4"
  sha256 "1cf2795fd0d7447be69f6714fba2d63d03d5ae53b562dc1fa96c7f87ceca54ab"

  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :el_capitan
    sha256 "0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "ignition-math2"
  depends_on "ignition-msgs"
  depends_on "ignition-transport2"
  depends_on "ignition-transport3"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt5"
  depends_on "qwt"
  depends_on "sdformat4"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"

  depends_on "ossp-uuid" => :linked
  depends_on "zeromq" => :linked

  depends_on "bullet" => [:recommended, "with-shared", "with-double-precision"]
  depends_on "dartsim/dart/dartsim4" => [:optional, "core-only"]
  depends_on "ffmpeg" => :optional
  depends_on "gdal" => :optional
  depends_on "gts" => :optional
  depends_on "player" => :optional
  depends_on "simbody" => :recommended

  conflicts_with "gazebo1", :because => "Differing version of the same formula"
  conflicts_with "gazebo2", :because => "Differing version of the same formula"
  conflicts_with "gazebo3", :because => "Differing version of the same formula"
  conflicts_with "gazebo4", :because => "Differing version of the same formula"
  conflicts_with "gazebo5", :because => "Differing version of the same formula"
  conflicts_with "gazebo6", :because => "Differing version of the same formula"
  conflicts_with "gazebo7", :because => "Differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
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
    system "#{bin}/gz", "sdf"
  end
end
