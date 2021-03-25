class Ogre22 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/3aa42f57f77a52febf0aedfc14ac83be37aafd4c.tar.gz"
  version "2.1.99999~pre0~0~20210319~3aa42f"
  sha256 "393110ab7a12a2011be4c261b4acddcb00c9b538fae2898ec2705f3d61592767"
  license "MIT"
  revision 2

  head "https://github.com/OGRECave/ogre-next.git", branch: "v2-2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
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
    url "https://gist.githubusercontent.com/j-rivero/9d800867870a0ca2a0e17949070f1f34/raw/4e412a58904df59d089957965214db1cfb5689ab/cmake3_c++11_ogre2.2_brew.patch"
    sha256 "4a3d90b351819d81bc4c02f1adb98c85865a8bb7e0a8070a6e7f23e6f037fd73"
  end

  patch do
    # import changes from master branch to get sysctl right on Mac
    url "https://gist.githubusercontent.com/j-rivero/3c34490b12434558e52521183dda4750/raw/2c0fe7029e5b9b80c1b011d1b9b4925bfbf610c1/sysctl_mac_from_master.patch"
    sha256 "c99abbcedaf5ba88f0740e091b12b2390177e4ed73c4863b01a53a59974043e2"
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

    # Move versioned libraries (*.2.2.0.dylib) to standard location and remove symlinks
    lib.install Dir[lib/"OGRE-2.2/lib*.2.2.0.dylib"]
    rm Dir[lib/"OGRE-2.2/lib*"]

    # Move plugins to subfolder
    (lib/"OGRE-2.2/OGRE").install Dir[lib/"OGRE-2.2/*.dylib"]

    # Restore lib symlinks
    Dir[lib/"lib*"].each do |l|
      (lib/"OGRE-2.2").install_symlink l => File.basename(l.sub(".2.2.0", ""))
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
