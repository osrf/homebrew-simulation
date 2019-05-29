class Gazebo10 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-10.1.0.tar.bz2"
  sha256 "8a1fcf8697704928c9cda610a9ce81f563f211bdfb2f1fdb458193ffb36c4287"
  revision 2

  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "d2de6351da929aa80111ef3918435641232a7a6270c7ff3728534dcf4d8b1c72" => :mojave
    sha256 "ad5484ea973f4a866d0ec2285f0dfaa3c5ea5acedd6cf309dfd8cf1f33721917" => :high_sierra
    sha256 "c642b509c1161cffc844226223a039301609d6d926eeb1e61f1682860084ef7f" => :sierra
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
  conflicts_with "gazebo9", :because => "Differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    # keep this patch
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Fix build with dartsim 6.8
    # remove this patch with next release
    url "https://bitbucket.org/osrf/gazebo/commits/5ba948b87faf98eb038fc3488e88a07bc4bd9df9/raw"
    sha256 "5f3738e04d8e23e3c49a6662e0029bfc94b8a1e2c142e084b7bd42f4d84bf993"
  end

  patch do
    # Fix build with dartsim 6.9
    # remove this patch with next release
    url "https://bitbucket.org/osrf/gazebo/commits/c7b7f62f76722d57e768b1d2b4c8371841bf856c/raw"
    sha256 "fa8b817197dcd8413904a97a7765580c8096060e68afc110b6ec6a6bf087268f"
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
