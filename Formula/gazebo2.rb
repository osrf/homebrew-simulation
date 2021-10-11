class Gazebo2 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-2.2.6.tar.bz2"
  sha256 "c5e886a9d43a99865d3393dab643493c906c106781ea2ee50555bb8dcf03bd81"
  license "Apache-2.0"
  head "https://github.com/osrf/gazebo.git", branch: "gazebo_2.2"

  deprecate! because: "is past end-of-life date", date: "2016-01-25"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "bullet"
  depends_on "cartr/qt4/qt@4"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "sdformat"
  depends_on "simbody"
  depends_on "tbb"
  depends_on "tinyxml"

  conflicts_with "gazebo3", because: "differing version of the same formula"
  conflicts_with "gazebo4", because: "differing version of the same formula"
  conflicts_with "gazebo5", because: "differing version of the same formula"
  conflicts_with "gazebo6", because: "differing version of the same formula"
  conflicts_with "gazebo7", because: "differing version of the same formula"
  conflicts_with "gazebo8", because: "differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Fix for compatibility with boost 1.58
    url "https://github.com/osrf/gazebo/commit/5f533662e72cf63c18f122a21cdc61599238d4c5.patch?full_index=1"
    sha256 "43453d5c7b97dc55ef88797dd488b7a7111de72521a2cdd44f8d68188e2db7ee"
  end

  patch do
    # Fix for compatibility with boost 1.62
    url "https://github.com/osrf/gazebo/commit/ff37ecfed0af9da0e9e98f26fa49217f51c4ac0f.patch?full_index=1"
    sha256 "374954bafa9cee8299839bc46039cf8296dd692878fabd2f87fabdee5bcddcca"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"
    cmake_args << "-DFORCE_GRAPHIC_TESTS_COMPILATION:BOOL=True"
    cmake_args << "-DDARTCore_FOUND:BOOL=False"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "gazebo", "--help"
  end
end
