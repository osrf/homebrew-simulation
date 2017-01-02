class Gazebo7 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-7.4.0.tar.bz2"
  sha256 "a033b2273383f16e5dd5b5bfe597551dc3618b98e64abecfa8a41bdddd6542f7"
  revision 3

  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo7", :using => :hg

  bottle do
    #root_url "http://gazebosim.org/distributions/ign-math/releases"
    root_url "http://px4-travis.s3.amazonaws.com/toolchain/bottles"
    rebuild 2
    sha256 "bf5b7d5aee51abb822f84ef584fbe46daf300c8ab06cdbbb1be822c1df6efdc3" => :el_capitan
    sha256 "68274d6c7b1a84ba3cbdabdb4328e3afe8e548cf405252b08176fa0637267588" => :yosemite
    sha256 "b7e9559955d9a3f1b4873d5b4df5d05c7c99503c8d50e640db1bd679c49af97e" => :sierra
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
  depends_on "px4/simulation/qt"
  depends_on "sdformat4"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"

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
