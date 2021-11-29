class Ogre22 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/312bf406a77244afe230930e67e3e5d52a119507.tar.gz"
  version "2.2.6+20211021~312bf40"
  sha256 "b9dbd84ef0c1731d0d1abc55499532358b9a9e5f0b3dc2b8e02ba76db0a112fd"
  license "MIT"

  head "https://github.com/OGRECave/ogre-next.git", branch: "v2-2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "3683309a6e4e5e4d2dd8de1bce25508624b537634c0dab4fc49df494a6ba9c6f"
    sha256 cellar: :any, catalina: "a02bd13e69b1c29744f617725bd70038cfde7695f3f55c66ac1545ab94c7b948"
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
    url "https://github.com/scpeters/ogre-next/commit/3486b772b35b3e5f8cf6da5b7a41e6c195408d7d.patch?full_index=1"
    sha256 "30a60758401980260f3a5abdd6513505327028a983af9e911908b4f7da140625"
  end

  patch do
    # implement override for MetalTextureGpu::getCustomAttribute
    url "https://github.com/OGRECave/ogre-next/commit/b7187a55a9ad5ba65ed24d1c212d1749833923ac.patch?full_index=1"
    sha256 "38975001bfa903194565ed0bf411cf29857cd5b2f0f71a651d64543f610c4ff6"
  end

  # patch do
  # fix GL3+ compilation with Xcode 10
  #  url "https://github.com/OGRECave/ogre-next/commit/b00a880a4aea5492615ce8e3363e81631a53bb5c.patch?full_index=1"
  #  sha256 "8fe5beab9e50dfe1f0164e8dbffd20a79f5e9afe79802ab0ce29d8d83e4e0fe8"
  # end

  def install
    cmake_args = [
      "-DOGRE_LIB_DIRECTORY=lib/OGRE-2.2",
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
    (share/"OGRE-2.2/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"

    # Support side-by-side OGRE installs
    # Rename executables to avoid conflicts with ogre2.1
    Dir[bin/"*"].each do |exe|
      mv exe, "#{exe}-2.2"
    end

    # Move headers
    (include/"OGRE-2.2").install Dir[include/"OGRE/*"]
    rmdir include/"OGRE"

    # Move and update .pc files
    lib.install Dir[lib/"OGRE-2.2/pkgconfig"]
    Dir[lib/"pkgconfig/*"].each do |pc|
      mv pc, pc.sub("pkgconfig/OGRE", "pkgconfig/OGRE-2.2")
    end
    inreplace Dir[lib/"pkgconfig/*"] do |s|
      s.gsub! prefix, opt_prefix
      s.sub! "Name: OGRE", "Name: OGRE-2.2"
      s.sub!(/^includedir=.*$/, "includedir=${prefix}/include/OGRE-2.2")
    end
    inreplace (lib/"pkgconfig/OGRE-2.2.pc"), " -I${includedir}\/OGRE", ""
    inreplace (lib/"pkgconfig/OGRE-2.2-MeshLodGenerator.pc"), "-I${includedir}/OGRE/", "-I${includedir}/"
    inreplace (lib/"pkgconfig/OGRE-2.2-Overlay.pc"), "-I${includedir}/OGRE/", "-I${includedir}/"

    # Move versioned libraries (*.2.2.6.dylib) to standard location and remove symlinks
    lib.install Dir[lib/"OGRE-2.2/lib*.2.2.6.dylib"]
    rm Dir[lib/"OGRE-2.2/lib*"]

    # Move plugins to subfolder
    (lib/"OGRE-2.2/OGRE").install Dir[lib/"OGRE-2.2/*.dylib"]

    # Restore lib symlinks
    Dir[lib/"lib*"].each do |l|
      (lib/"OGRE-2.2").install_symlink l => File.basename(l.sub(".2.2.6", ""))
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
    system "pkg-config", "OGRE-2.2"
    cflags = `pkg-config --cflags OGRE-2.2`.split
    libs = `pkg-config --libs OGRE-2.2`.split
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
