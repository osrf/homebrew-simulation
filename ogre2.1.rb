class Ogre21 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://bitbucket.org/sinbad/ogre/get/06a386fa64e79a7204a90faf53da1735743f6c2e.tar.bz2"
  version "2.0.9999~20180616~06a386f"
  sha256 "d2e28bfcfbb1277355047c1d8bcd141b05b83af52d277725168e4281eac92a6d"

  bottle do
    root_url "http://gazebosim.org/distributions/ogre/releases"
    sha256 "088deeb420ba6d058962eca59a58967f54280b197669c5dc59fa3cb06071417a" => :high_sierra
    sha256 "ade07317c6ca515204be1ef64b4d8c87e60732e6d426d100447587a611235c4c" => :sierra
    sha256 "115c6af607d0844bc3d51f65933a0394dc23c40a5c3453a1c37abdb7e74b81cb" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "libzzip"
  depends_on "tbb"
  depends_on :x11

  conflicts_with "ogre", :because => "Differing version of the same formula"
  conflicts_with "ogre1.9", :because => "Differing version of the same formula"

  patch do
    # fix for cmake3 and c++11
    url "https://gist.github.com/scpeters/4a7516b52c6e918ac02cbacabfeda4b3/raw/c515f8f313c444b306dfff9d437ec7cf3622ab12/cmake3.diff"
    sha256 "99d76e023cd5740da66c76ced40ce85e7da7b811ea99d9015d1293fc454badc0"
  end

  # workaround for test since OgreMeshTool can't find plugins_tools.cfg otherwise
  patch :DATA

  def install
    ENV.m64

    cmake_args = [
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_BUILD_DOCS:BOOL=FALSE",
      "-DOGRE_INSTALL_DOCS:BOOL=FALSE",
      "-DOGRE_BUILD_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=FALSE",
    ]
    cmake_args.concat std_cmake_args

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # Put these cmake files where Debian puts them
    (share/"OGRE/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"

    # Put these cfg files in share instead of bin
    (share/"OGRE/cfg").install Dir[prefix/"bin/*.cfg"]
  end

  test do
    (testpath/"test.mesh.xml").write <<-EOS
      <mesh>
        <submeshes>
          <submesh material="BaseWhite" usesharedvertices="false" use32bitindexes="false" operationtype="triangle_list">
            <faces count="1">
              <face v1="0" v2="1" v3="2" />
            </faces>
            <geometry vertexcount="3">
              <vertexbuffer positions="true" normals="false" texture_coords="0">
                <vertex>
                  <position x="-50" y="-50" z="50" />
                </vertex>
                <vertex>
                  <position x="-50" y="-50" z="-50" />
                </vertex>
                <vertex>
                  <position x="50" y="-50" z="-50" />
                </vertex>
              </vertexbuffer>
            </geometry>
          </submesh>
        </submeshes>
        <submeshnames>
          <submeshname name="submesh0" index="0" />
        </submeshnames>
      </mesh>
    EOS
    system "#{bin}/OgreMeshTool", "#{testpath}/test.mesh.xml"
    system "du", "-h", "#{testpath}/test.mesh"
  end
end

__END__
diff -r d8213f4fb1db Tools/MeshTool/src/main.cpp
--- a/Tools/MeshTool/src/main.cpp       Thu Jun 14 19:05:19 2018 -0300
+++ b/Tools/MeshTool/src/main.cpp       Mon Jun 18 16:43:28 2018 -0700
@@ -1125,7 +1125,7 @@
     SetCurrentDirectoryW( pathName.c_str() );
 #else
     //This ought to work in Unix, but I didn't test it, otherwise try setenv()
-    //chdir( fullAppPath.GetPath().mb_str() );
+    chdir( "/usr/local/share/OGRE/cfg" );
 #endif
     //Most Ogre materials assume floating point to use radix point, not comma.
     //Prevent awfull number truncation in non-US systems
@@ -1139,7 +1139,7 @@
     SetCurrentDirectoryW( gWorkingDir );
 #else
     //This ought to work in Unix, but I didn't test it, otherwise try setenv()
-    //chdir( fullAppPath.GetPath().mb_str() );
+    chdir( "/usr/local/share/OGRE/cfg" );
 #endif
 }
 

