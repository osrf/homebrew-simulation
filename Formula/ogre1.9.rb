class Ogre19 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://ogrecave.github.io/ogre/"
  url "https://osrf-distributions.s3.amazonaws.com/ogre/releases/sinbad-ogre-108ab0bcc696.tar.bz2"
  version "1.9-20160714-108ab0bcc69603dba32c0ffd4bbbc39051f421c9"
  sha256 "3ca667b959905b290d782d7f0808e35d075c85db809d3239018e4e10e89b1721"
  license "MIT"
  revision 11

  head "https://github.com/OGRECave/ogre.git", branch: "master"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "8eb999e92b356251d6a5676089a0656a8556cf9c92e817c5d95f7bb9185e1696"
    sha256 cellar: :any, ventura: "87c237e4b2428721d62b74e74273942d037646015851ff3e5dd7c671102eeeac"
  end

  option "with-cg"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libzzip"
  depends_on "tbb"

  conflicts_with "ogre", because: "differing version of the same formula"

  patch do
    url "https://gist.githubusercontent.com/marvinosswald/0e981e918aeee4403e9a0790c6f32cdd/raw/5d295499255867064ace8c4c41b2f31fd48d4576/gistfile1.txt"
    sha256 "62d33adbb3d46f9354ba9486226ee88649d7d7af0e26354f69c5cc777dd2ef86"
  end

  patch do
    url "https://gist.github.com/NikolausDemmel/2b11d1b49b35cd27a102/raw/bf4a4d16020821218f73db0d56aa111ab2fde679/fix-1.9-HEAD.diff"
    sha256 "15ecd1f12266918650ea789e2f96da4b0ef1a96076d7a671d3c56d98e2459712"
  end

  patch do
    # retain osx cocoa window
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

  patch do
    # fix FindOGRE.cmake for non-framework builds
    url "https://gist.githubusercontent.com/iche033/2b5e2ba31436881f1db29f9b60c7a5b2/raw/b6ab953ebd82127ad1177744f367a36e059312a9/ogre-1.9-findogre.patch"
    sha256 "7ca6f549fbdff7b7fc334f06da4547e071ec0e3f2733897fc6ef0d2bfa1716a3"
  end

  patch do
    # fix for boost 1.65
    url "https://github.com/OGRECave/ogre/commit/cade48b4c2215dd77ea74b7aa219a22c2a5d6654.patch?full_index=1"
    sha256 "d30c9a941b436c920cdb7a56e870e6a07921d1188ba3e0d8934323fdd28fc7c2"
  end

  patch do
    # fix for boost 1.67
    url "https://github.com/OGRECave/ogre/commit/2371c8d001725190a9cda62dc5df282cde78f951.patch?full_index=1"
    sha256 "28d418f7c978bedcf26c7a53c0f621fd5d9a2f27e5b838ea03af00e062f65470"
  end

  # fix for finding ZZip
  patch do
    url "https://github.com/scpeters/ogre/commit/8fcfe0885e6bd98d971250d4a3fb9a23e3743dfd.patch?full_index=1"
    sha256 "3a69a4ed9e86887d3a23b0882c9868e994ab710205bb2e4b87204a8c89f1a3c5"
  end

  # fix for m1 cpu arch
  patch do
    url "https://github.com/scpeters/ogre/commit/c39b6df49618773357da0b54437f351b57168d12.patch?full_index=1"
    sha256 "fa8dc20d5978d1ff1402a4df890a6fa0ca1fec6ec73f00154f7484820516b071"
  end

  # fix for OgreUTFString.h on newer clang
  patch do
    url "https://gist.githubusercontent.com/mrpollo/70a1fa1413d52227d0f9b5b2aa934442/raw/974f144e4c17d623f4bf90258876b38a90ef6018/ogre1.9-macos15-utfstring-fix.patch"
    sha256 "01c35413f9b544cc67282709614065af5826a9a450d039a3027ff3819aaaab8c"
  end

  def install
    cmake_args = [
      "-DCMAKE_CXX_STANDARD='14'",
      "-DOGRE_BUILD_DOCS:BOOL=FALSE",
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      "-DOGRE_BUILD_SAMPLES:BOOL=FALSE",
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_INSTALL_DOCS:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=FALSE",
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
      "-DOGRE_STRING_USE_UTF16=OFF",
      "-DCMAKE_MACOSX_RPATH=ON",
      "-DCMAKE_INSTALL_RPATH=#{lib}",
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
    system "#{bin}/OgreXMLConverter", "test.mesh.xml"
    system "du", "-h", "./test.mesh"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
