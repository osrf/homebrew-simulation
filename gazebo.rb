require 'formula'

class Gazebo < Formula
  homepage 'http://gazebosim.org'
  url 'http://gazebosim.org/assets/distributions/gazebo-1.9.1.tar.bz2'
  sha1 '265df282577ec99ea38bbdb1005910e5772e4d85'
  head 'https://bitbucket.org/osrf/gazebo', :branch => 'default', :using => :hg

  depends_on 'boost'
  depends_on 'cmake'  => :build
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'libtar'
  depends_on 'ogre'
  depends_on 'pkg-config' => :build
  depends_on 'protobuf'
  depends_on 'protobuf-c'
  depends_on 'qt'
  depends_on 'tbb'
  depends_on 'tinyxml'
  depends_on 'sdformat'

  depends_on 'bullet' => [:optional, 'shared', 'double-precision']
  # can't figure out how to specify optional gem dependency
  #depends_on 'ronn' => [:ruby, :optional]

  def patches; DATA; end

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_BUILD_TYPE='Release'",
      "-DCMAKE_INSTALL_PREFIX='#{prefix}'",
      "-DCMAKE_FIND_FRAMEWORK=LAST",
      "-Wno-dev",
      "-DENABLE_TESTS_COMPILATION:BOOL=False",
      "-DFORCE_GRAPHIC_TESTS_COMPILATION:BOOL=True",
    ]
    #cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make install"
    end
  end
end

__END__
diff -r 032eec53d401 deps/opende/CMakeLists.txt
--- a/deps/opende/CMakeLists.txt  Tue Aug 20 12:44:18 2013 -0700
+++ b/deps/opende/CMakeLists.txt  Sat Sep 28 22:18:43 2013 -0700
@@ -3,7 +3,7 @@
 include (CheckFunctionExists)
 include (CheckLibraryExists)

-include_directories(SYSTEM
+include_directories(
   ${CMAKE_CURRENT_BINARY_DIR} 
   ${CMAKE_SOURCE_DIR}/deps/opende/include
   ${CMAKE_SOURCE_DIR}/deps/opende/ou/include
