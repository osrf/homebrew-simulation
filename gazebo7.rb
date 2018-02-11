class Gazebo7 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-7.10.0.tar.bz2"
  sha256 "9c7fe24339aaec0cdf2e7664282dc0982a7110da344316f12d0e673608b52244"
  revision 1

  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo7", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    sha256 "c83a929c043314349ccc88e4ff62fbd94e88cb1a5591225e54cd1e6b5479b31e" => :high_sierra
    sha256 "245458c845bc95b741237640c8b4bb1458264cc1e286d17a08c6941ffe3fbe6f" => :sierra
    sha256 "41dbe7c3bad42aba3c7fbbe2751b82e414ecc85c7fd0a7f1bca30f92f14e5ca2" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "ignition-math2"
  depends_on "ignition-transport"
  depends_on "libtar"
  depends_on "ogre1.9"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "cartr/qt4/qt@4"
  depends_on "sdformat4"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"

  depends_on "bullet" => :recommended
  depends_on "dartsim/dart/dartsim4" => :optional
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
  conflicts_with "gazebo8", :because => "Differing version of the same formula"

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
