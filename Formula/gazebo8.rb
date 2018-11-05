class Gazebo8 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-8.6.0.tar.bz2"
  sha256 "c62aeb4a0a761a3685c7f8caa63e8f8ba588ab2ce5ac7b956c6ddeb1ada7be88"
  revision 3
  version_scheme 1

  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "graphviz"
  depends_on "ignition-math3"
  depends_on "ignition-msgs0"
  depends_on "ignition-transport3"
  depends_on "libtar"
  depends_on "ogre1.9"
  depends_on "ossp-uuid" => :linked
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt"
  depends_on "qwt"
  depends_on "sdformat5"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2@6.2.0"
  depends_on "zeromq" => :linked

  depends_on "bullet" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "gts" => :recommended
  depends_on "simbody" => :recommended
  depends_on "dartsim/dart/dartsim4" => :optional
  depends_on "gdal" => :optional
  depends_on "player" => :optional

  conflicts_with "gazebo2", :because => "Differing version of the same formula"
  conflicts_with "gazebo3", :because => "Differing version of the same formula"
  conflicts_with "gazebo4", :because => "Differing version of the same formula"
  conflicts_with "gazebo5", :because => "Differing version of the same formula"
  conflicts_with "gazebo6", :because => "Differing version of the same formula"
  conflicts_with "gazebo7", :because => "Differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    # keep this patch
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DQWT_WIN_INCLUDE_DIR=#{HOMEBREW_PREFIX}/lib/qwt.framework/Headers"
    cmake_args << "-DQWT_WIN_LIBRARY_DIR=#{HOMEBREW_PREFIX}/lib/qwt.framework"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{bin}/gz", "sdf"
  end
end
