class Gazebo9 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-9.8.0.tar.bz2"
  sha256 "6846c38fd4fbd735379a0be65ccf15c8dea07e52f33598ceebb5e6e60e8de7b0"

  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "e4e3d31fe039b0f12005162dedb8447c44a809f59673876f78f25e4df841a8b2" => :mojave
    sha256 "0f2e6bbe17aa9ade96d08f6cfb52e1f779edfe6db22a7aad4fa34923a9e260fe" => :high_sierra
    sha256 "aec2267ab9b8781378f5888125d1fd4400bfd174161ecc3a9b755a1acd613d2a" => :sierra
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
  conflicts_with "gazebo10", :because => "Differing version of the same formula"

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
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
