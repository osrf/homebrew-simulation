class Gazebo9 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-9.0.0.tar.bz2"
  sha256 "2c29955d476c97dc0ccbb1c8295ec6e8ffe203d7bc6047c1f34433a82ab9215e"
  revision 6

  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    sha256 "d0a727888b784de68e6dfbbc2cf32f15af83f82f93baba580fa2ee32eb129855" => :high_sierra
    sha256 "6da22009c396dbdc5b4fd220f0a9a21bd9829ba39e8c4cf0d96992612ff4352b" => :sierra
    sha256 "aede7b7ca114ff9ce92ca470902a56def4ddf559439395fdcd77383927892325" => :el_capitan
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
    # Fix find_package(DART) in gazebo-config.cmake
    url "https://bitbucket.org/osrf/gazebo/commits/74ee141ddd25beb508ec595464638abc54a835c6/raw"
    sha256 "5e4b177a29dda37a663440faaa83c17be26cb9c3c1b4bfa13e9865650de1370e"
  end

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
