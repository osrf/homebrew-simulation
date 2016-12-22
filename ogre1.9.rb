class Ogre19 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "http://www.ogre3d.org/"
  url "https://bitbucket.org/sinbad/ogre/get/108ab0bcc69603dba32c0ffd4bbbc39051f421c9.tar.bz2"
  version "1.9-20160714-108ab0bcc69603dba32c0ffd4bbbc39051f421c9"
  sha256 "3ca667b959905b290d782d7f0808e35d075c85db809d3239018e4e10e89b1721"

  bottle do
    root_url "http://gazebosim.org/distributions/ogre/releases"
    sha256 "3960b3c177fa81d2b37f3784bceeafd4f10788d7fcbb228934056f4bb61f40ff" => :el_capitan
    sha256 "f56d6421e44373fa77b4411e2c71fa04575f8e2bba3dd0e8c3226a9dd4c609e1" => :yosemite
  end

  option "with-cg"

  depends_on "boost"
  depends_on "cmake" => :build
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "libzzip"
  depends_on "tbb"
  depends_on :x11

  patch do
    url "https://gist.github.com/NikolausDemmel/2b11d1b49b35cd27a102/raw/bf4a4d16020821218f73db0d56aa111ab2fde679/fix-1.9-HEAD.diff"
    sha256 "15ecd1f12266918650ea789e2f96da4b0ef1a96076d7a671d3c56d98e2459712"
  end

  patch do
    # this is the same patch as hgaiser's `window.patch` above, but applicable to the latest 1.9 version
    url "https://gist.githubusercontent.com/NikolausDemmel/927bd7bb3f14c1788599/raw/c9a5ba88b758e80d3f46511629c4e8026b92c462/ogre1.9.patch"
    sha256 "e82d842138f7f5ff4637ed313d1140c3b868c8425d4cdba7a71e0a9d7f7e0fd6"
  end

  patch do
    # disable building samples if ois is not available
    url "https://gist.githubusercontent.com/iche033/68349eebfc436e484b70e6e3508ae27b/raw/d96227cd79ed1d63f051689a18c95a1c174a4efa/ogre-1.9-ois.patch"
    sha256 "7ad630740217ccb9f48898507e9c6713dcd37a677a9669cdc16ef39afbf68826"
  end

  patch do
    # link against AGL framework
    url "https://gist.githubusercontent.com/iche033/b73766fac9ab3d628a79b5ed986677cd/raw/878d0902704c7fb51511163052c95294361f1dbe/ogre-1.9-agl.patch"
    sha256 "8122c7eb52faae0fdedb70278d24e2581c88d1181de4d6e94d27bc1b3e596181"
  end

  patch do
    # backport cocoa window fix to support contents scaling factor (for retina displays)
    url "https://gist.githubusercontent.com/iche033/e0080a592c890cc9a4fce31f6863a5ed/raw/875ae8ad1d9f0eaa271fd44eab8e0979bac74119/ogre-1.9-cocoa_window_scale.patch"
    sha256 "c20c288530ea4d11b37f9c8b30cb43c89722c85eac0af3b6520cd89c37014e5b"
  end

  patch do
    # add libc++ flag
    url "https://gist.githubusercontent.com/iche033/e2b152d9df080b21f71ba3b65aa39922/raw/5397fa149c7570c17f2d78421d44b12dfa175387/ogre-1.9-cxx_flags.patch"
    sha256 "7dc77285029c34b4a6adb52b0d4b9c40578526a5e9764d0a7091c6a4cb63fa78"
  end

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
    cmake_args << "-DOGRE_BUILD_PLUGIN_CG=OFF" if build.without? "cg"
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make", "install"
    end

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

  test do
    (testpath/"test.mesh.xml").write <<-EOS.undent
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
    system "#{bin}/OgreXMLConverter", "test.mesh.xml"
    system "du", "-h", "./test.mesh"
  end
end
