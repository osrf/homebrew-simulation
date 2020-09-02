class Gazebo8 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-8.6.0.tar.bz2"
  sha256 "c62aeb4a0a761a3685c7f8caa63e8f8ba588ab2ce5ac7b956c6ddeb1ada7be88"
  license "Apache-2.0"
  revision 5
  version_scheme 1

  head "https://github.com/osrf/gazebo", branch: "gazebo8"

  deprecate! because: "is past end-of-life date", date: "2019-01-25"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "protobuf-c" => :build

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
  depends_on "qt"
  depends_on "qwt"
  depends_on "sdformat5"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "zeromq" => :linked

  depends_on "bullet" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "gts" => :recommended
  depends_on "simbody" => :recommended
  depends_on "dartsim/dart/dartsim4" => :optional
  depends_on "gdal" => :optional
  depends_on "player" => :optional

  conflicts_with "gazebo2", because: "differing version of the same formula"
  conflicts_with "gazebo3", because: "differing version of the same formula"
  conflicts_with "gazebo4", because: "differing version of the same formula"
  conflicts_with "gazebo5", because: "differing version of the same formula"
  conflicts_with "gazebo6", because: "differing version of the same formula"
  conflicts_with "gazebo7", because: "differing version of the same formula"

  patch do
    # Fix for compatibility with boost 1.69
    url "https://github.com/osrf/gazebo/commit/69fcced27c1df15719f626eb3dc4721540a1de63.diff?full_index=1"
    sha256 "2cdb4e9400c4d8d7242cd25d26efd0db89f885da13584d46977e66c1bea77fe4"
  end

  patch do
    # Fix for compatibility with boost 1.69
    url "https://github.com/osrf/gazebo/commit/9c3fa7f66e5d8333b7b6bf5349e53eff2cb11bc0.diff?full_index=1"
    sha256 "87e2522508c6588f2f3279b0c1a449e70ee942d1385ddd32f97e71b8fc76d5f7"
  end

  patch do
    # Fix for compatibility with boost 1.68
    url "https://github.com/osrf/gazebo/commit/3555b9021931f404b39195f51af1b07c4ee0df9c.diff?full_index=1"
    sha256 "b282821d34f62b0a2ce1e46f737f39d2183ed1435a1a353c0c806b3c8741a787"
  end

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
