class ChronoEngine < Formula
  homepage "http://www.projectchrono.org/chronoengine/"
  url "https://github.com/projectchrono/chrono/archive/2.0.0.tar.gz"
  sha256 "ef5d5831881bc2fc6f3f80106e6e763c904f57dc39b6db880968f00451ac936b"
  head "https://github.com/projectchrono/chrono.git", :branch => "develop"

  depends_on "cmake" => :build
  depends_on "irrlicht" => :optional

  fails_with :clang do
    build 503
    cause "HACD problem"
  end

  # Fix irrlicht demos: incorrect path to data folder
  patch :DATA if build.head?

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_UNIT_IRRLICHT=True" if build.with?("irrlicht") && build.head?

    mkdir "build" do
      system "cmake", "../src", *cmake_args
      system "make", "install"
    end
  end

  def caveats
    s = ""

    if build.with?("irrlicht") && !build.head?
      s += "The '--with-irrlicht' option requires '--HEAD'"
      s += ", irrlicht demos are disabled"
    end
    s.empty? ? nil : s
  end
end
__END__
diff --git a/src/CMakeLists.txt b/src/CMakeLists.txt
index b1a1f43..839cf44 100644
--- a/src/CMakeLists.txt
+++ b/src/CMakeLists.txt
@@ -199,6 +199,8 @@ ELSEIF(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        endif()
     SET (CPACK_SYSTEM_NAME "OSX-x64")
 ENDIF()
+SET (CHRONO_DATA_PATH ${CMAKE_INSTALL_PREFIX}/data/)
+SET (CH_BUILDFLAGS "${CH_BUILDFLAGS} -DCHRONO_DATA_PATH=\"${CHRONO_DATA_PATH}\"")
 
 #-----------------------------------------------------------------------------
 # Some global  C++ definitions and includes that are used 
diff --git a/src/demos/irrlicht/CMakeLists.txt b/src/demos/irrlicht/CMakeLists.txt
index 8bcb338..3e2f7b8 100644
--- a/src/demos/irrlicht/CMakeLists.txt
+++ b/src/demos/irrlicht/CMakeLists.txt
@@ -50,7 +50,7 @@ FOREACH(PROGRAM ${DEMOS})
 
   SET_TARGET_PROPERTIES(${PROGRAM}  PROPERTIES
     FOLDER demos
-    COMPILE_FLAGS "${CH_BUILDFLAGS}"
+    COMPILE_FLAGS "${CH_BUILDFLAGS} -DDATA_PREFIX=${CMAKE_INSTALL_PREFIX}/data"
     LINK_FLAGS "${CH_LINKERFLAG_EXE}"
     )
 
diff --git a/src/physics/ChGlobal.cpp b/src/physics/ChGlobal.cpp
index 1e46aa4..7be7e76 100644
--- a/src/physics/ChGlobal.cpp
+++ b/src/physics/ChGlobal.cpp
@@ -84,7 +84,9 @@ int GetUniqueIntID()
 // Functions for manipulating the Chrono data directory
 // -----------------------------------------------------------------------------
 
-static std::string chrono_data_path("../data/");
+#define STRINGIFY(s) XSTR(s)
+#define XSTR(s) #s
+static std::string chrono_data_path(STRINGIFY(CHRONO_DATA_PATH));
 
 // Set the path to the Chrono data directory (ATTENTION: not thread safe)
 void SetChronoDataPath(const std::string& path)

