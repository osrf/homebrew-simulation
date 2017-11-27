class IgnitionSensors < Formula
  desc "Common libraries for robotics applications. Sensors Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/3abcc7ff6b9b1e81b1acc1119a5038647864fe35.tar.gz"
  version "0.0.0~20170721~374ce93"
  sha256 "85561f6e7f61e6744e57d8cc2fb8d3d443f31e6c7d81c7eeebfba334fa2044a8"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  #bottle do
  #  rebuild 1
  #  root_url "http://gazebosim.org/distributions/ign-sensors/releases"
  #  sha256 "a435130d701ebdaa58bd29833a26d53c612ae2163a195b0124ad71f0e54675d8" => :high_sierra
  #  sha256 "8660bbd506869aebc3c01114af9fa651d4ee67eaa9259748a7fc4204aeb01c08" => :sierra
  #  sha256 "ab9346c2e57d496cc71275d44f6091c6e0792913ca5cc1c88af97e5f099bb37a" => :el_capitan
  #end

  depends_on "cmake" => :build

  depends_on "ignition-msgs1"
  depends_on "ignition-common0"
  depends_on "ignition-math4"
  depends_on "ignition-transport4"
  depends_on "ignition-rendering"
  depends_on "sdformat6"

  depends_on "pkg-config" => :run

  # Use ign-transport4
  patch :DATA

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent

	#include <iostream>

	#include <ignition/rendering.hh>
	#include <ignition/sensors.hh>

	int main()
	{
	  // Setup ign-rendering with a scene
	  auto *engine = ignition::rendering::engine("ogre");
	  if (!engine)
	  {
		std::cerr << "Failed to load ogre\n";
		return 1;
	  }
	  ignition::rendering::ScenePtr scene = engine->CreateScene("scene");

	  // Add stuff to take a picture of
	  BuildScene(scene);

	  // Create a sensor manager
	  ignition::sensors::Manager mgr;
	  mgr.SetRenderingScene(scene);

      return 0;
    }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-sensors"
    cflags   = `pkg-config --cflags ignition-sensors`.split(" ")
    ldflags  = `pkg-config --libs ignition-sensors`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end

__END__
diff -r 3abcc7ff6b9b cmake/SearchForStuff.cmake
--- a/cmake/SearchForStuff.cmake	Fri Nov 10 19:23:07 2017 +0000
+++ b/cmake/SearchForStuff.cmake	Mon Nov 27 14:48:30 2017 +0100
@@ -34,9 +34,9 @@
 
 ################################################################################
 # Ignition transport
-find_package(ignition-transport3 QUIET)
-if (NOT ignition-transport3_FOUND)
-  BUILD_ERROR ("Missing: Ignition transport (libignition-transport3-dev)")
+find_package(ignition-transport4 QUIET)
+if (NOT ignition-transport4_FOUND)
+  BUILD_ERROR ("Missing: Ignition transport (libignition-transport4-dev)")
 else()
   message (STATUS "Found Ignition transport")
 endif()
diff -r 3abcc7ff6b9b src/Manager.cc
--- a/src/Manager.cc	Fri Nov 10 19:23:07 2017 +0000
+++ b/src/Manager.cc	Mon Nov 27 14:51:12 2017 +0100
@@ -90,15 +90,15 @@
 {
   auto fullPath = this->systemPaths.FindSharedLibrary(_desc.fileName);
   if (fullPath.empty())
-    return false;
+    return nullptr;
 
   auto pluginName = pl.LoadLibrary(fullPath);
   if (pluginName.empty())
-    return false;
+    return nullptr;
 
   auto instance = pl.Instantiate<Sensor>(pluginName);
   if (!instance)
-    return false;
+    return nullptr;
 
   // Shared pointer so others can access plugins
   std::shared_ptr<Sensor> sharedInst = std::move(instance);
diff -r 0df33bc4be48 cmake/SearchForStuff.cmake
--- a/cmake/SearchForStuff.cmake	Mon Nov 27 15:55:06 2017 +0100
+++ b/cmake/SearchForStuff.cmake	Mon Nov 27 16:13:09 2017 +0100
@@ -34,11 +34,17 @@
 
 ################################################################################
 # Ignition transport
-find_package(ignition-transport4 QUIET)
-if (NOT ignition-transport4_FOUND)
-  BUILD_ERROR ("Missing: Ignition transport (libignition-transport4-dev)")
-else()
-  message (STATUS "Found Ignition transport")
+set(IGNITION-TRANSPORT_REQUIRED_MAJOR_VERSION 4)
+if (NOT DEFINED IGNITION-TRANSPORT_LIBRARY_DIRS AND NOT DEFINED IGNITION-TRANSPORT_INCLUDE_DIRS AND NOT DEFINED IGNITION-TRANSPORT_LIBRARIES)
+  find_package(ignition-transport${IGNITION-transport_REQUIRED_MAJOR_VERSION} QUIET)
+  if (NOT ignition-transport${IGNITION-TRANSPORT_REQUIRED_MAJOR_VERSION}_FOUND)
+    message(STATUS "Looking for ignition-transport${IGNITION-TRANSPORT_REQUIRED_MAJOR_VERSION}-config.cmake - not found, trying ignition-transport3 instead")
+    set(IGNITION-TRANSPORT_REQUIRED_MAJOR_VERSION 3)
+    find_package(ignition-transport3 QUIET)
+    if (NOT ignition-transport3_FOUND)
+      BUILD_ERROR ("Missing: Ignition transport4 or Ignition transport3 library.")
+    endif()
+  endif()
 endif()
 
 ################################################################################
diff -r 0df33bc4be48 cmake/ignition-config.cmake.in
--- a/cmake/ignition-config.cmake.in	Mon Nov 27 15:55:06 2017 +0100
+++ b/cmake/ignition-config.cmake.in	Mon Nov 27 16:13:09 2017 +0100
@@ -31,7 +31,7 @@
 
 include(CMakeFindDependencyMacro)
 find_dependency(ignition-math4)
-find_dependency(ignition-transport3)
+find_dependency(ignition-transport@IGNITION-TRANSPORT_REQUIRED_MAJOR_VERSION@ REQUIRED)
 find_dependency(ignition-rendering0)
 find_dependency(ignition-common0)
 find_dependency(SDFormat 6)
