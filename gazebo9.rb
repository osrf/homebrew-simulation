class Gazebo9 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-9.3.0.tar.bz2"
  sha256 "01bda8489e6260fe86dff402e1e37a818e56f4ad4da431e6a284bdd44f2dc33f"

  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    sha256 "eb594fb86a7b97dc80803d7b302a83d350c59805d823e7ce99a5e8709f0d4e6d" => :high_sierra
    sha256 "84bb50f528babe309604df3236ffcc853b713677f9ca3d4a9666c3d9bc3f50ac" => :sierra
    sha256 "ab4bef5f76a7fc4fa5e38d4ee35ab3638def18ad80a5a64cc00aa400b75bb34a" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "ignition-fuel-tools1"
  depends_on "ignition-math4"
  depends_on "ignition-msgs1"
  depends_on "ignition-transport4"
  depends_on "libtar"
  depends_on "ogre1.9"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt"
  depends_on "qwt"
  depends_on "sdformat6"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"

  depends_on "ossp-uuid" => :linked
  depends_on "zeromq" => :linked

  depends_on "bullet" => :recommended
  depends_on "dartsim" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "gdal" => :optional
  depends_on "gts" => :recommended
  depends_on "player" => :optional
  depends_on "simbody" => :recommended

  conflicts_with "gazebo2", :because => "Differing version of the same formula"
  conflicts_with "gazebo3", :because => "Differing version of the same formula"
  conflicts_with "gazebo4", :because => "Differing version of the same formula"
  conflicts_with "gazebo5", :because => "Differing version of the same formula"
  conflicts_with "gazebo6", :because => "Differing version of the same formula"
  conflicts_with "gazebo7", :because => "Differing version of the same formula"
  conflicts_with "gazebo8", :because => "Differing version of the same formula"

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
