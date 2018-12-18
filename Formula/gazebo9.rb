class Gazebo9 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-9.6.0.tar.bz2"
  sha256 "289a78e09d1a49f55df2d3c72930f474f12b492c65d368af4f0e97e6dc4d1d19"

  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "25f231bc41b978a55b7da177acada2319932bcc26c6784bef7d84750fb9a4ece" => :mojave
    sha256 "8f4fdec14671ffaee2b3b1cf5189c76e835e3af4a8767d0b4e60e8fafb4b73d3" => :high_sierra
    sha256 "3d07d33e0ce8523638b3cd8bfe82492e80a1bb5bfb6ebd35e617e48f6f3d5501" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "graphviz"
  depends_on "ignition-fuel-tools1"
  depends_on "ignition-math4"
  depends_on "ignition-msgs1"
  depends_on "ignition-transport4"
  depends_on "libtar"
  depends_on "ogre1.9"
  depends_on "ossp-uuid" => :linked
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt"
  depends_on "qwt"
  depends_on "sdformat6"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "zeromq" => :linked

  depends_on "bullet" => :recommended
  depends_on "dartsim" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "gts" => :recommended
  depends_on "simbody" => :recommended
  depends_on "gdal" => :optional
  depends_on "player" => :optional

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
