class Ogre22 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/ec3f70cb53a8a7e5d196855d0274ac03f90a2f4c.tar.gz"
  version "2.2.5+20210824~ec3f70c"
  sha256 "0bddbca05a8c5ca8a33eddeffdbce2aa1ca5a2035dbb7f2a1b67637a3851464f"
  license "MIT"

  head "https://github.com/OGRECave/ogre-next.git", branch: "v2-2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "656887a4da9407d87c2ad3d47054a213dead2ebd66cd5ee4734950f53b18234c"
    sha256 cellar: :any, mojave:   "e16590ac4c338d0a05f30cc8cd58530609501ce88499f93f74eb9400a367fe61"
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
