require 'formula'

class Ogre19 < Formula
  homepage 'http://www.ogre3d.org/'

  url 'https://bitbucket.org/sinbad/ogre/get/v1-9-0.tar.gz'
  version '1.9.0'
  sha1 'dd1c0a27ff76a34d3c0daf7534ab9cd16e399f86'

  head 'https://bitbucket.org/sinbad/ogre', :using => :hg

  patch :DATA

  depends_on 'boost'
  depends_on 'cmake' => :build
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'freetype'
  depends_on 'libzzip'
  depends_on 'tbb'
  depends_on :x11

  option 'with-cg'

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_OSX_ARCHITECTURES='x86_64'",
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_BUILD_DOCS:BOOL=FALSE",
      "-DOGRE_INSTALL_DOCS:BOOL=FALSE",
      "-DOGRE_BUILD_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=FALSE",
    ]
    cmake_args << "-DOGRE_BUILD_PLUGIN_CG=OFF" unless build.include? "with-cg"
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make install"
    end

    # FIXME: for now we build with doc and samples OFF, so config files, media
    #        and docs are not present

    # remove config files from bin directory
#     (share/'OGRE/config').install Dir[bin/"macosx/*.cfg"]
#     rmdir bin/"macosx"
#
#     (share/"OGRE/").install prefix/"Media"
#     rmdir prefix/"Media"
#
#     (doc/"OGRE").install Dir[prefix/"Docs/*"]
#     rmdir prefix/"Docs"

    # Put these cmake files where Debian puts them
    (share/"OGRE/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"

    # This is necessary because earlier versions of Ogre seem to have created
    # the plugins with "lib" prefix and software like "rviz" now has Mac
    # specific code that looks for the plugins with "lib" prefix. Hence we add
    # symlinks with the "lib" prefix manually, but their use is deprecated.
    Dir.glob(lib/"OGRE/*.dylib") do |path|
      filename = File.basename(path)
      symlink path, lib/"OGRE/lib#{filename}"
    end

  end
end

__END__
diff -r dd30349ea667 CMake/Utils/OgreConfigTargets.cmake
--- a/CMake/Utils/OgreConfigTargets.cmake	Sun Dec 01 11:28:12 2013 -0600
+++ b/CMake/Utils/OgreConfigTargets.cmake	Thu Jul 17 21:24:12 2014 +0200
@@ -71,7 +71,7 @@
     set(OGRE_LIB_RELEASE_PATH "/Release")
   endif(APPLE AND OGRE_BUILD_PLATFORM_APPLE_IOS)
   if (APPLE)
-    set(OGRE_PLUGIN_PATH "/")
+    set(OGRE_PLUGIN_PATH "/OGRE")
   else()
     set(OGRE_PLUGIN_PATH "/OGRE")
   endif(APPLE)
@@ -103,11 +103,11 @@

 	if(EXPORT)
 	  install(TARGETS ${TARGETNAME} #EXPORT Ogre-exports
-		BUNDLE DESTINATION "bin${OGRE_RELEASE_PATH}" CONFIGURATIONS Release None ""
-		RUNTIME DESTINATION "bin${OGRE_RELEASE_PATH}" CONFIGURATIONS Release None ""
+		BUNDLE DESTINATION "bin" CONFIGURATIONS Release None ""
+		RUNTIME DESTINATION "bin" CONFIGURATIONS Release None ""
 		LIBRARY DESTINATION "${OGRE_LIB_DIRECTORY}${OGRE_LIB_RELEASE_PATH}${SUFFIX}" CONFIGURATIONS Release None ""
 		ARCHIVE DESTINATION "${OGRE_LIB_DIRECTORY}${OGRE_LIB_RELEASE_PATH}${SUFFIX}" CONFIGURATIONS Release None ""
-		FRAMEWORK DESTINATION "${OGRE_LIB_DIRECTORY}${OGRE_RELEASE_PATH}/Release" CONFIGURATIONS Release None ""
+		FRAMEWORK DESTINATION "Frameworks" CONFIGURATIONS Release None ""
       )
 	  install(TARGETS ${TARGETNAME} #EXPORT Ogre-exports
 		BUNDLE DESTINATION "bin${OGRE_RELWDBG_PATH}" CONFIGURATIONS RelWithDebInfo
@@ -133,11 +133,11 @@
 	  #install(EXPORT Ogre-exports DESTINATION ${OGRE_LIB_DIRECTORY})
 	else()
 	  install(TARGETS ${TARGETNAME}
-		BUNDLE DESTINATION "bin${OGRE_RELEASE_PATH}" CONFIGURATIONS Release None ""
-		RUNTIME DESTINATION "bin${OGRE_RELEASE_PATH}" CONFIGURATIONS Release None ""
+		BUNDLE DESTINATION "bin" CONFIGURATIONS Release None ""
+		RUNTIME DESTINATION "bin" CONFIGURATIONS Release None ""
 		LIBRARY DESTINATION "${OGRE_LIB_DIRECTORY}${OGRE_LIB_RELEASE_PATH}${SUFFIX}" CONFIGURATIONS Release None ""
 		ARCHIVE DESTINATION "${OGRE_LIB_DIRECTORY}${OGRE_LIB_RELEASE_PATH}${SUFFIX}" CONFIGURATIONS Release None ""
-		FRAMEWORK DESTINATION "${OGRE_LIB_DIRECTORY}${OGRE_RELEASE_PATH}/Release" CONFIGURATIONS Release None ""
+		FRAMEWORK DESTINATION "Frameworks" CONFIGURATIONS Release None ""
       )
 	  install(TARGETS ${TARGETNAME}
 		BUNDLE DESTINATION "bin${OGRE_RELWDBG_PATH}" CONFIGURATIONS RelWithDebInfo
@@ -251,7 +251,7 @@
 endfunction(ogre_config_component)

 function(ogre_config_framework LIBNAME)
-  if (APPLE AND NOT OGRE_BUILD_PLATFORM_APPLE_IOS)
+  if (OGRE_BUILD_LIBS_AS_FRAMEWORKS)
       set_target_properties(${LIBNAME} PROPERTIES FRAMEWORK TRUE)

       # Set the INSTALL_PATH so that frameworks can be installed in the application package
diff -r dd30349ea667 CMakeLists.txt
--- a/CMakeLists.txt	Sun Dec 01 11:28:12 2013 -0600
+++ b/CMakeLists.txt	Thu Jul 17 21:24:12 2014 +0200
@@ -391,6 +391,7 @@
 cmake_dependent_option(OGRE_BUILD_XSIEXPORTER "Build the Softimage exporter" FALSE "Softimage_FOUND" FALSE)
 option(OGRE_BUILD_TESTS "Build the unit tests & PlayPen" FALSE)
 option(OGRE_CONFIG_DOUBLE "Use doubles instead of floats in Ogre" FALSE)
+cmake_dependent_option(OGRE_BUILD_LIBS_AS_FRAMEWORKS "Build frameworks for libraries on OS X." TRUE "APPLE;NOT OGRE_BUILD_PLATFORM_APPLE_IOS" FALSE)

 if (OGRE_BUILD_PLATFORM_WINRT)
 # WinRT can only use the standard allocator
diff -r dd30349ea667 OgreMain/CMakeLists.txt
--- a/OgreMain/CMakeLists.txt	Sun Dec 01 11:28:12 2013 -0600
+++ b/OgreMain/CMakeLists.txt	Thu Jul 17 21:24:12 2014 +0200
@@ -334,7 +334,9 @@
   endif ()

   # Framework is called 'Ogre'
-  set_target_properties(OgreMain PROPERTIES	OUTPUT_NAME Ogre)
+  if (OGRE_BUILD_LIBS_AS_FRAMEWORKS)
+    set_target_properties(OgreMain PROPERTIES	OUTPUT_NAME Ogre)
+  endif ()
 endif ()
 target_link_libraries(OgreMain ${LIBRARIES})
 if (MINGW)

