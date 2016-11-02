class Gazebo3 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "http://gazebosim.org/distributions/gazebo/releases/gazebo-3.2.0.tar.bz2"
  sha256 "6b77382a491833d5292b3e1fca34a04c968025a09746d87cdcf77cff040acea5"
  head "https://bitbucket.org/osrf/gazebo", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "libtar"
  depends_on "ogre"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt"
  depends_on "sdformat"
  depends_on "tbb"
  depends_on "tinyxml"

  depends_on "bullet" => [:optional, "with-shared", "with-double-precision"]
  depends_on "dartsim/dart/dartsim" => [:optional, "core-only"]
  depends_on "ffmpeg" => :optional
  depends_on "gts" => :optional
  depends_on "player" => :optional
  depends_on "simbody" => :optional

  conflicts_with "gazebo1", :because => "Differing version of the same formula"
  conflicts_with "gazebo2", :because => "Differing version of the same formula"
  conflicts_with "gazebo4", :because => "Differing version of the same formula"
  conflicts_with "gazebo5", :because => "Differing version of the same formula"
  conflicts_with "gazebo6", :because => "Differing version of the same formula"
  conflicts_with "gazebo7", :because => "Differing version of the same formula"
  conflicts_with "gazebo8", :because => "Differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Fix build with protobuf 2.6 (gazebo #1289)
    url "https://bitbucket.org/osrf/gazebo/commits/4bb4390655af316b582f8e0fea23438426b4e681/raw/"
    sha256 "70d39a547aa27a5357ddf0859d41515c945730ca1cef770be3c0cff2e29340d2"
  end

  patch do
    # Disable gdal dependency for now (see gazebo issue #1063)
    url "https://gist.githubusercontent.com/scpeters/9199351/raw/6c90b487def89bff54ad5ad0688110d806063aa0/disable_gdal.patch"
    sha256 "61f327b3373c5b5a12cec4de03c1111c74e03a03aee7b426ddd04b598901ddbf"
  end

  patch do
    # Fix build with boost 1.57 (gazebo #1399)
    url "https://bitbucket.org/osrf/gazebo/commits/39f8398003ada7381dc03096f666627e84c738eb/raw/"
    sha256 "6d38b6f01491f0419d70d72c067a69b75dfc3ac4520b4ceaeb7f0da9436b4a37"
  end

  patch do
    # Fix for compatibility with boost 1.58
    url "https://bitbucket.org/osrf/gazebo/commits/91f6f3c59f40af34855548c37857955d08fd1368/raw/"
    sha256 "1a8b232be58f36bf5fa0129169f4d4d40d72624b460735457c781ba3e02c7900"
  end

  # Fix whitespace before next patch
  patch :DATA

  patch do
    # Another fix with boost 1.57 (gazebo #1399)
    url "https://bitbucket.org/osrf/gazebo/commits/34e70706a56709a5c3a2a5ef4e79e271fcaa4e9c/raw/"
    sha256 "3e7946107855a88a72862c3efe0931f0862b94f6641e21258e21dae8690246d5"
  end

  def install
    ENV.m64

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

