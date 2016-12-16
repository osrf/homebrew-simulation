class Ogre < Formula
  desc "Object-Oriented Graphics Rendering Engine"
  homepage "http://www.ogre3d.org/"
  url "https://downloads.sourceforge.net/project/ogre/ogre/1.7/ogre_src_v1-7-4.tar.bz2"
  version "1.7.4"
  sha256 "afa475803d9e6980ddf3641dceaa53fcfbd348506ed67893c306766c166a4882"
  head "https://bitbucket.org/sinbad/ogre", :branch => "v1-9", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ogre/releases"
    sha256 "8041b0541b4aa3bd57ed53ad83f10acc0c98e5aa622cad362bc2c280cadab3af" => :el_capitan
    sha256 "193c5c5eb56ed471fd5d9c73ed0dc2c6c41c17b75df2ae7174c7d66ff1cfba38" => :yosemite
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

  # https://gist.github.com/4237236
  patch do
    url "https://gist.github.com/wjwwood/4237236/raw/e357f1b9fa8b26d02ed84f411d5b5eb7446c68c5/pkg_config_fix.patch"
    sha256 "a2296a0e505906a09add6534fcc6f60ce598bb56b7fd422953cf92dbfee3ac00"
  end unless build.head?
  patch do
    url "https://gist.github.com/wjwwood/4237236/raw/57cb907304433cc0bb83fd332ff98a5789102b00/prevent_framework_apple.patch"
    sha256 "1416fd5dc44f5e219bf7a675888aad53c5f9a4f0596ff35ccdb7ef2a7f7d60a9"
  end unless build.head?
  patch do
    url "https://gist.github.com/wjwwood/4237236/raw/31ae53cefdb693cb2fb81333178163a29f8cf7ca/osx_isystem.patch"
    sha256 "a9b010ac15a662a58e13e425d9dde64c2edb04f06650394e8c2b12e451120a4e"
  end unless build.head?
  patch do
    url "https://gist.github.com/wjwwood/4237236/raw/9c7df6689da4e0b358429692f6615f2707469f45/osx_linking.patch"
    sha256 "3d971465cf251eaea6d39538b92e9f3a0fbaf7fe3f0e8add10aeadde9f12c338"
  end unless build.head?
  patch do
    url "https://gist.github.com/wjwwood/4237236/raw/d667813d5ee1e712e0ea8cc99df9a85da6141b1e/replace_pbxcp_with_ditto.patch"
    sha256 "990abb97fd1a5410a8a557915c8f16d2507133973d6c073acc59b8d0696f8c4d"
  end unless build.head?
  patch do
    url "https://gist.github.com/wjwwood/5672104/raw/bf69b4528b3090ad99a760029beb75b7aeb11248/fix_boost_linking.patch"
    sha256 "6962171371f55ad6cc4c6310078c6f563ddc0ae25152b77e4da24d2d8ce2eecb"
  end unless build.head?
  patch do
    url "https://gist.github.com/hgaiser/7346167/raw/3167c2fde153618e55b37f857ef4a90cc54ed2a3/ogre.patch"
    sha256 "f81ddf3c6974857311816b2f2c2f974c6365d154f9273bf7c5b5fc37867bb292"
  end unless build.head?
  patch do
    url "https://gist.github.com/scpeters/b9034c613189426c2d6a/raw/b74a4c1fb795a69b42d1189dc2a35fac3b975959/ogre_agl.diff"
    sha256 "010413134085b2849491541f887e6fdc63bf87824689411dd9a9d3d06664b7f2"
  end unless build.head?

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_OSX_ARCHITECTURES='x86_64'",
    ]
    cmake_args << "-DOGRE_BUILD_PLUGIN_CG=OFF" if build.without? "cg"
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make", "install"
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
