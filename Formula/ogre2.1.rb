class Ogre21 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/b4c4fa785c03c2d4ba2a1d28d94394c7ca000358.tar.gz"
  version "2.0.99999~pre0~0~20180616~06a386f"
  sha256 "c9580c2380669c1de170612609f2f122c08cd88393a75ad53535e433c8feb72d"
  license "MIT"

  head "https://github.com/OGRECave/ogre-next", branch: "v2-1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    rebuild 1
    sha256 "1c1603e76240f8cccd10f839d67ffa726c8b66b60ceb499249cf84cb850ca2a1" => :mojave
    sha256 "c300233dd9589c60576fcfb2d4f22dd3c788bdae9cc44550e7d9855bf7ad89e7" => :high_sierra
    sha256 "553e77a967dbb8e58a2f2033517fe932ad2d6e50ee568e82585b384175eea653" => :sierra
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

  patch do
    # fix for cmake3 and c++11
    url "https://gist.github.com/scpeters/4a7516b52c6e918ac02cbacabfeda4b3/raw/c515f8f313c444b306dfff9d437ec7cf3622ab12/cmake3.diff"
    sha256 "99d76e023cd5740da66c76ced40ce85e7da7b811ea99d9015d1293fc454badc0"
  end

  patch do
    # fix GL3+ compilation with Xcode 10
    url "https://github.com/OGRECave/ogre-next/commit/b00a880a4aea5492615ce8e3363e81631a53bb5c.diff?full_index=1"
    sha256 "cb16e12a5caa6a44c3891f23bbd9af120c9e31172b1b1eb65e350c8aefa0bf89"
  end

  def install
    ENV.m64

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
      s.sub! /^includedir=.*$/, "includedir=${prefix}/include/OGRE-2.1"
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
    cflags = `pkg-config --cflags OGRE-2.1`.split(" ")
    libs = `pkg-config --libs OGRE-2.1`.split(" ")
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
