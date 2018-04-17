class Gazebo7 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-7.12.0.tar.bz2"
  sha256 "6d96b464c2808e68033c8f81d7686a7ef27b2d6a652f34811e9cb55876d2c3f5"
  revision 1

  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo7", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    sha256 "9ab200b5e5d7b79087bad0b8a5b02720dacd154de08891d6ab74976d64bc6eeb" => :high_sierra
    sha256 "161a7a4207073591516a8ff869e622d09a73cbd86ba051de9946b5ffa0c89a03" => :sierra
    sha256 "5bdc17637e3cfc41c1650de2dd092546d9f28611dbce8030a3da5df5255cbc8a" => :el_capitan
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

  patch do
    # Fix for compatibility with boost 1.67 error_code
    url "https://bitbucket.org/osrf/gazebo/commits/d6155b6481d4d0cd6ec02f2b8d16679fa1a051b0/raw/"
    sha256 "f109ccb2b3f79a09dffd061039ba89e830e5ff62388d9d6632066f17621e726c"
  end

  patch do
    # Fix for compatibility with boost 1.67 posix_time
    url "https://bitbucket.org/osrf/gazebo/commits/441bbe5f2e2490d99610eb90015cf5cc9cdd2e18/raw/"
    sha256 "b73dd0e1ca7b49ce75fe6577dbc56f161ad8c7fe72bd3ff01ad31eb4a6641496"
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
