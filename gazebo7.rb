class Gazebo7 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-7.8.1.tar.bz2"
  sha256 "c884842378ef435f70a106eb10e96da3455a26db6d6b892f99148d2748f98840"
  revision 1

  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo7", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    sha256 "1af7cbf8c132b10e62e9283f01d017ab1a2304fae2f263907b36c54bd28e961e" => :sierra
    sha256 "e23e68631ffc5fb54fc26be456e636c1f5e75bdbfe08809b90784bf44462bb88" => :el_capitan
    sha256 "abb72bad5f319d897014a0a93842072014c360229296bddf1a6216cff0fb8cc7" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "ignition-math2"
  depends_on "ignition-transport"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "cartr/qt4/qt@4"
  depends_on "sdformat4"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"

  depends_on "bullet" => :recommended
  depends_on "dartsim/dart/dartsim4" => :optional
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
