class Ogre23 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/refs/tags/v2.3.1.tar.gz"
  sha256 "38dd0d5ba5759ee47c71552c5dacf44dad5fe61868025dcbd5ea6a6bdb6bc8e4"
  license "MIT"
  revision 2

  # head "https://github.com/OGRECave/ogre-next.git", branch: "v2-3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:   "00e8a7721f3a33eb5f5df26c70a597e71ee06328949cecae7e85c79badf8a34f"
    sha256 cellar: :any, ventura:  "a99ca4c5adc6c3455d9df29aa00c944f3dddb2ff64c176cb37efc759b8bc1498"
    sha256 cellar: :any, monterey: "58e4f7a6d4e1ae1a70b2f449801b4335deb378dc982f38f2bc3cfc6393a5e0b0"
    sha256 cellar: :any, big_sur:  "2cd52cc99ea96660c7a83e2c5458c900f0abd4af3fdd7b69117ad87b407d0a2a"
  end

  depends_on "cmake" => :build
  depends_on "gz-plugin2" => :test
  depends_on "pkgconf" => :test

  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "libx11"
  depends_on "libzzip"
  depends_on "rapidjson"
  depends_on "tbb"

  patch do
    # Fix for compatibility with XCode 16.3
    url "https://github.com/scpeters/ogre-next/commit/b7439ae047489aa104a6775a99a9e93294c3d5b5.patch?full_index=1"
    sha256 "d56016cd237c9a98e7c4389c57a455ea5d660d538d0cb1d5082bb2f9ed4e00b8"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"OGRE-2.3", target: lib),
      rpath(source: lib/"OGRE-2.3/OGRE", target: lib),
    ]
    cmake_args = [
      "-DCMAKE_CXX_STANDARD=11",
      "-DCMAKE_CXX_STANDARD_REQUIRED:BOOL=ON",
      "-DCMAKE_CXX_EXTENSIONS:BOOL=ON",
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
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
    # Rename executables to avoid conflicts with ogre2.1 and ogre2.2
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
    inreplace (lib/"pkgconfig/OGRE-2.3.pc"), " -I${includedir}/OGRE", ""
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
    require "system_command"
    extend SystemCommand::Mixin
    # test plugins in subfolders
    ["libOgreMain", "libOgreOverlay", "libOgrePlanarReflections", "OGRE/RenderSystem_Metal"].each do |plugin|
      p = lib/"OGRE-2.3/#{plugin}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    end
    # build against API
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
