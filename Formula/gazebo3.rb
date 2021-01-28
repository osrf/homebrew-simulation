class Gazebo3 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-3.2.0.tar.bz2"
  sha256 "6b77382a491833d5292b3e1fca34a04c968025a09746d87cdcf77cff040acea5"
  license "Apache-2.0"
  head "https://github.com/osrf/gazebo.git", branch: "gazebo_3.1"

  deprecate! because: "is past end-of-life date", date: "2015-07-27"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "protobuf-c" => :build

  depends_on "boost"
  depends_on "bullet"
  depends_on "cartr/qt4/qt@4"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "sdformat"
  depends_on "simbody"
  depends_on "tbb"
  depends_on "tinyxml"

  conflicts_with "gazebo2", because: "differing version of the same formula"
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
    # Fix build with protobuf 2.6 (gazebo #1289)
    url "https://github.com/osrf/gazebo/commit/1ef108cc501a2e839278c9510f744640b8cfc903.patch?full_index=1"
    sha256 "6dbb74296b39f62186e4a06f6e84642855292a016c197033c60c983c0a6d6b2c"
  end

  patch do
    # Disable gdal dependency for now (see gazebo issue #1063)
    url "https://gist.githubusercontent.com/scpeters/9199351/raw/6c90b487def89bff54ad5ad0688110d806063aa0/disable_gdal.patch"
    sha256 "61f327b3373c5b5a12cec4de03c1111c74e03a03aee7b426ddd04b598901ddbf"
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

  # Fix whitespace before next patch
  patch :DATA

  patch do
    # Another fix with boost 1.57 (gazebo #1399)
    url "https://github.com/osrf/gazebo/commit/205d42a5cb9ad7a749a8cb6ba6b56d7751b5653d.patch?full_index=1"
    sha256 "c47369217eebec023fb1b8c13bd1fea65e5b928d829c2c8021a8c6b9c39c21f1"
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
    system "#{bin}/gz", "sdf"
  end
end

__END__
diff -r 890dd3dddb9e tools/CMakeLists.txt
--- a/tools/CMakeLists.txt	Thu Nov 20 18:28:10 2014 +0100
+++ b/tools/CMakeLists.txt	Wed Jan 07 17:50:26 2015 -0800
@@ -7,7 +7,7 @@
   ${SDF_INCLUDE_DIRS}
 )
 
-link_directories( 
+link_directories(
   ${SDF_LIBRARY_DIRS}
   ${tinyxml_LIBRARY_DIRS}
 )

