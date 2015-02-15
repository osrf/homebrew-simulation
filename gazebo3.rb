require 'formula'

class Gazebo3 < Formula
  homepage 'http://gazebosim.org'
  url 'http://gazebosim.org/distributions/gazebo/releases/gazebo-3.2.0.tar.bz2'
  sha1 '8aeb7b6612ed15e3e945ee031ea22347baa79d80'
  head 'https://bitbucket.org/osrf/gazebo', :branch => 'default', :using => :hg

  depends_on 'cmake'  => :build
  depends_on 'pkg-config' => :build

  depends_on 'boost'
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'libtar'
  depends_on 'ogre'
  depends_on 'protobuf'
  depends_on 'protobuf-c'
  depends_on 'qt'
  depends_on 'sdformat'
  depends_on 'tbb'
  depends_on 'tinyxml'

  depends_on 'bullet' => [:optional, 'shared', 'double-precision']
  depends_on 'dartsim/dart/dartsim' => [:optional, 'core-only']
  depends_on 'ffmpeg' => :optional
  depends_on 'gts' => :optional
  depends_on 'player' => :optional
  depends_on 'simbody' => :optional

  patch do
    # Fix build when homebrew python is installed
    url 'https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch'
    sha1 'eaa6f843ab1264810c0c0a81ff3c52232fd49d12'
  end

  patch do
    # Fix build with protobuf 2.6 (gazebo #1289)
    url 'https://bitbucket.org/osrf/gazebo/commits/4bb4390655af316b582f8e0fea23438426b4e681/raw/'
    sha1 '4b149bdfb0a95c08d76c724f11f7a9780a3759fa'
  end

  patch do
    # Disable gdal dependency for now (see gazebo issue #1063)
    url 'https://gist.githubusercontent.com/scpeters/9199351/raw/6c90b487def89bff54ad5ad0688110d806063aa0/disable_gdal.patch'
    sha1 'fc258137ab82d2a6b922f46f345366e72e96c1b8'
  end

  patch do
    # Fix build with boost 1.57 (gazebo #1399)
    url 'https://bitbucket.org/osrf/gazebo/commits/39f8398003ada7381dc03096f666627e84c738eb/raw/'
    sha1 'd7439de6508149cfa1c11058f0e626037e6c1552'
  end

  # Fix whitespace before next patch
  patch :DATA

  patch do
    # Another fix with boost 1.57 (gazebo #1399)
    url 'https://bitbucket.org/osrf/gazebo/commits/34e70706a56709a5c3a2a5ef4e79e271fcaa4e9c/raw/'
    sha1 'bb5c42d593ad31f8c41c1fc99af7716bc5e8563f'
  end

  def install
    ENV.m64

    cmake_args = std_cmake_args.select { |arg| arg.match(/CMAKE_BUILD_TYPE/).nil? }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"
    cmake_args << "-DFORCE_GRAPHIC_TESTS_COMPILATION:BOOL=True"
    cmake_args << "-DDARTCore_FOUND:BOOL=False"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make install"
    end
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

