class GazeboAT1 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-1.9.7.tar.bz2"
  sha256 "27f3f81d3b11f997e8879e660445e49e81f8d15909ef7352b166c5050c61573a"
  license "Apache-2.0"
  head "https://github.com/osrf/gazebo.git", branch: "gazebo_1.9"

  keg_only "old version of gazebo"

  deprecate! because: "is past end-of-life date", date: "2015-07-27"

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

  patch do
    # Fix build when homebrew python is installed
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Fix build with protobuf 2.6 (gazebo #1289)
    url "https://github.com/osrf/gazebo/commit/1ef108cc501a2e839278c9510f744640b8cfc903.patch?full_index=1"
    sha256 "6dbb74296b39f62186e4a06f6e84642855292a016c197033c60c983c0a6d6b2c"
  end

  patch do
    # Fix build with boost 1.57 (gazebo #1399)
    url "https://github.com/osrf/gazebo/commit/7c185d822403750467da05289b8ff681c122a2f8.patch?full_index=1"
    sha256 "c5259ecacbdb11496e0b36600dc26ba9a7ccafc6c8d6c8365c84618e834b3234"
  end

  patch do
    # Fix for compatibility with boost 1.58
    url "https://github.com/osrf/gazebo/commit/5f533662e72cf63c18f122a21cdc61599238d4c5.patch?full_index=1"
    sha256 "43453d5c7b97dc55ef88797dd488b7a7111de72521a2cdd44f8d68188e2db7ee"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"
    cmake_args << "-DFORCE_GRAPHIC_TESTS_COMPILATION:BOOL=True"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "gazebo", "--help"
  end
end
