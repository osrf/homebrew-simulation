class Ogre21 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://bitbucket.org/sinbad/ogre/get/06a386fa64e79a7204a90faf53da1735743f6c2e.tar.bz2"
  version "2.0.99999~pre0~0~20180616~06a386f"
  sha256 "d2e28bfcfbb1277355047c1d8bcd141b05b83af52d277725168e4281eac92a6d"

  head "https://bitbucket.org/sinbad/ogre", :branch => "v2-1", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "e1f3e42863ce7cd5f8da8b70ce62b3fc01eb9ad4b7b4fcd6840eda4940f3e215" => :mojave
    sha256 "fddac650048e82dfa25ace0cbc5602e65c8e58e99120f59be10e8101d18261af" => :high_sierra
    sha256 "9e9cbae5a7f64ad6f6b20458403e61352a9a80cc8df3198551801c6521690503" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :test
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "libzzip"
  depends_on "rapidjson"
  depends_on "tbb"
  depends_on :x11

  conflicts_with "ogre", :because => "Differing version of the same formula"
  conflicts_with "ogre1.9", :because => "Differing version of the same formula"

  patch do
    # fix for cmake3 and c++11
    url "https://gist.github.com/scpeters/4a7516b52c6e918ac02cbacabfeda4b3/raw/c515f8f313c444b306dfff9d437ec7cf3622ab12/cmake3.diff"
    sha256 "99d76e023cd5740da66c76ced40ce85e7da7b811ea99d9015d1293fc454badc0"
  end

  patch do
    # fix GL3+ compilation with Xcode 10
    url "https://bitbucket.org/sinbad/ogre/commits/14b5dc7fc2d8e1281140d027e1effb4d8a317895/raw"
    sha256 "41c678d3021feab844c5731c0cc2aa7007b731cfde5e084bc87d3a1eba9fa581"
  end

  def install
    ENV.m64

    cmake_args = [
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_BUILD_DOCS:BOOL=FALSE",
      "-DOGRE_INSTALL_DOCS:BOOL=FALSE",
      "-DOGRE_BUILD_SAMPLES:BOOL=FALSE",
      "-DOGRE_BUILD_SAMPLES2:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=FALSE",
    ]
    # use the following to disable GL3Plus render engine which won't work when OpenGL is removed
    # cmake_args << "-DOGRE_BUILD_RENDERSYSTEM_GL3PLUS:BOOL=OFF" if MacOS::Xcode.version >= "10"
    cmake_args.concat std_cmake_args

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # Put these cmake files where Debian puts them
    (share/"OGRE/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <Ogre.h>
      int main()
      {
        Ogre::Root *root = new Ogre::Root("", "", "");
        delete root;
        return 0;
      }
    EOS
    system "pkg-config", "OGRE"
    cflags = `pkg-config --cflags OGRE`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-std=c++11",
                   "-L#{lib}",
                   "-lOgreMain",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
