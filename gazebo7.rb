class Gazebo7 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-7.4.0.tar.bz2"
  sha256 "a033b2273383f16e5dd5b5bfe597551dc3618b98e64abecfa8a41bdddd6542f7"
  revision 4

  head "https://bitbucket.org/osrf/gazebo", :branch => "gazebo7", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/gazebo/releases"
    sha256 "bf5b7d5aee51abb822f84ef584fbe46daf300c8ab06cdbbb1be822c1df6efdc3" => :el_capitan
    sha256 "68274d6c7b1a84ba3cbdabdb4328e3afe8e548cf405252b08176fa0637267588" => :yosemite
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
  depends_on "qt4-no-webkit"
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

  patch do
    # Remove dependence on webkit from qt4, part 1
    url "https://bitbucket.org/osrf/gazebo/commits/12bbbf5f0968eeb26be7f3d0c441d83edd070dac/raw/"
    sha256 "77bf176e2fcb8bc4fe751ad0fd205df390a1e9aa9bca2ad42620a4362257286c"
  end

  patch do
    # Remove dependence on webkit from qt4, part2
    url "https://bitbucket.org/osrf/gazebo/commits/33a8a3c3d631f2c48056d4c35942a9899e1db585/raw/"
    sha256 "16df786e372926aebc24c4d2f28d0e6fa72b83f3e7372c9c5d82271e73c9a93f"
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
