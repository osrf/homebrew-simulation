class Ogre23 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/refs/tags/v2.3.1.tar.gz"
  sha256 "38dd0d5ba5759ee47c71552c5dacf44dad5fe61868025dcbd5ea6a6bdb6bc8e4"
  license "MIT"
  revision 1

  head "https://github.com/OGRECave/ogre-next.git", branch: "v2-3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "c7bc82c7ffed7af79d74e7a9fc84c7c174869bbd797bfb8f818b55a05b36af86"
    sha256 cellar: :any, big_sur:  "d1a6802fc6866492073fa56800424c01e232820f3ab7b00031a1ec00115a73f4"
    sha256 cellar: :any, catalina: "51d97c4d9a057983863425cce7df566fd2665ef81aa1bf7ac4600ecacd1c0252"
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

  def install
    cmake_args = [
      "-DCMAKE_CXX_STANDARD=11",
      "-DCMAKE_CXX_STANDARD_REQUIRED:BOOL=ON",
      "-DCMAKE_CXX_EXTENSIONS:BOOL=ON",
      "-DOGRE_BUILD_RENDERSYSTEM_GL3PLUS:BOOL=TRUE",
      "-DOGRE_BUILD_RENDERSYSTEM_METAL:BOOL=TRUE",
      "-DOGRE_BUILD_COMPONENT_HLMS:BOOL=TRUE",
      "-DOGRE_BUILD_COMPONENT_HLMS_PBS:BOOL=ON",
      "-DOGRE_BUILD_COMPONENT_HLMS_UNLIT:BOOL=ON",
      "-DOGRE_BUILD_COMPONENT_OVERLAY:BOOL=ON",
      "-DOGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS:BOOL=ON",
      "-DOGRE_LIB_DIRECTORY=lib/OGRE-2.3",
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_INSTALL_DOCS:BOOL=FALSE",
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
    (share/"OGRE-2.3/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"

    # Support side-by-side OGRE installs
    # Rename executables to avoid conflicts with ogre2.1
    Dir[bin/"*"].each do |exe|
      mv exe, "#{exe}-2.3"
    end

    # Move headers
    (include/"OGRE-2.3").install Dir[include/"OGRE/*"]
    rmdir include/"OGRE"

    # Move and update .pc files
    lib.install Dir[lib/"OGRE-2.3/pkgconfig"]
    Dir[lib/"pkgconfig/*"].each do |pc|
      mv pc, pc.sub("pkgconfig/OGRE", "pkgconfig/OGRE-2.3")
    end
    inreplace Dir[lib/"pkgconfig/*"] do |s|
      s.gsub! prefix, opt_prefix
      s.sub! "Name: OGRE", "Name: OGRE-2.3"
      s.sub!(/^includedir=.*$/, "includedir=${prefix}/include/OGRE-2.3")
    end
    inreplace (lib/"pkgconfig/OGRE-2.3.pc"), " -I${includedir}\/OGRE", ""
    inreplace (lib/"pkgconfig/OGRE-2.3-MeshLodGenerator.pc"), "-I${includedir}/OGRE/", "-I${includedir}/"
    inreplace (lib/"pkgconfig/OGRE-2.3-Overlay.pc"), "-I${includedir}/OGRE/", "-I${includedir}/"

    # Move versioned libraries (*.2.2.6.dylib) to standard location and remove symlinks
    lib.install Dir[lib/"OGRE-2.3/lib*.2.3.1.dylib"]
    rm Dir[lib/"OGRE-2.3/lib*"]

    # Move plugins to subfolder
    (lib/"OGRE-2.3/OGRE").install Dir[lib/"OGRE-2.3/*.dylib"]

    # Restore lib symlinks
    Dir[lib/"lib*"].each do |l|
      (lib/"OGRE-2.3").install_symlink l => File.basename(l.sub(".2.3.1", ""))
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
    system "pkg-config", "OGRE-2.3"
    cflags = `pkg-config --cflags OGRE-2.3`.split
    libs = `pkg-config --libs OGRE-2.3`.split
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
