class Ogre21 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/b4c4fa785c03c2d4ba2a1d28d94394c7ca000358.tar.gz"
  version "2.0.99999~pre0~0~20180616~06a386f"
  sha256 "c9580c2380669c1de170612609f2f122c08cd88393a75ad53535e433c8feb72d"
  license "MIT"
  revision 1

  head "https://github.com/OGRECave/ogre-next.git", branch: "v2-1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    rebuild 1
    sha256 cellar: :any, catalina: "d29874b82f0f942bd7d2453e145cd74382734a1d4161b25d7ac0e8efd4b41928"
    sha256 cellar: :any, mojave:   "f0b505985d282e7dd8b1aecc7daf51ff15c8fbb58b4b30c556fbc139ec878075"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :test
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libzzip"
  depends_on "rapidjson"
  depends_on "tbb"

  patch do
    # fix for cmake3 and c++11
    url "https://gist.github.com/scpeters/4a7516b52c6e918ac02cbacabfeda4b3/raw/c515f8f313c444b306dfff9d437ec7cf3622ab12/cmake3.diff"
    sha256 "99d76e023cd5740da66c76ced40ce85e7da7b811ea99d9015d1293fc454badc0"
  end

  patch do
    # fix GL3+ compilation with Xcode 10
    url "https://github.com/OGRECave/ogre-next/commit/b00a880a4aea5492615ce8e3363e81631a53bb5c.patch?full_index=1"
    sha256 "8fe5beab9e50dfe1f0164e8dbffd20a79f5e9afe79802ab0ce29d8d83e4e0fe8"
  end

  patch do
    # fix GL3+ cocoa window and useCurrentGLContext
    url "https://github.com/ignition-forks/ogre-2.1-release/compare/b4c4fa785c03c2d4ba2a1d28d94394c7ca000358..81632330e3ab041345c7fa1075022cf6af30c658.diff"
    sha256 "9a855a9e60bc81874e3d1501094e1fcc46d296ac964ca8985ddeb1035fe05cd2"
  end

  def install
    cmake_args = [
      "-DOGRE_LIB_DIRECTORY=lib/OGRE-2.1",
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
    (share/"OGRE-2.1/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"

    # Support side-by-side OGRE installs
    # Move headers
    (include/"OGRE-2.1").install Dir[include/"OGRE/*"]
    rmdir include/"OGRE"

    # Move and update .pc files
    lib.install Dir[lib/"OGRE-2.1/pkgconfig"]
    Dir[lib/"pkgconfig/*"].each do |pc|
      mv pc, pc.sub("pkgconfig/OGRE", "pkgconfig/OGRE-2.1")
    end
    inreplace Dir[lib/"pkgconfig/*"] do |s|
      s.gsub! prefix, opt_prefix
      s.sub! "Name: OGRE", "Name: OGRE-2.1"
      s.sub!(/^includedir=.*$/, "includedir=${prefix}/include/OGRE-2.1")
    end
    inreplace (lib/"pkgconfig/OGRE-2.1.pc"), " -I${includedir}\/OGRE", ""
    inreplace (lib/"pkgconfig/OGRE-2.1-MeshLodGenerator.pc"), "-I${includedir}/OGRE/", "-I${includedir}/"
    inreplace (lib/"pkgconfig/OGRE-2.1-Overlay.pc"), "-I${includedir}/OGRE/", "-I${includedir}/"

    # Move versioned libraries (*.2.1.0.dylib) to standard location and remove symlinks
    lib.install Dir[lib/"OGRE-2.1/lib*.2.1.0.dylib"]
    rm Dir[lib/"OGRE-2.1/lib*"]

    # Move plugins to subfolder
    (lib/"OGRE-2.1/OGRE").install Dir[lib/"OGRE-2.1/*.dylib"]

    # Restore lib symlinks
    Dir[lib/"lib*"].each do |l|
      (lib/"OGRE-2.1").install_symlink l => File.basename(l.sub(".2.1.0", ""))
    end
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
    system "pkg-config", "OGRE-2.1"
    cflags = `pkg-config --cflags OGRE-2.1`.split
    libs = `pkg-config --libs OGRE-2.1`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-std=c++11",
                   *libs,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
