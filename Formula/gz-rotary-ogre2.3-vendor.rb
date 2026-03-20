class GzRotaryOgre23Vendor < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/refs/tags/v2.3.3.tar.gz"
  sha256 "92ce7765d892d6424df3d8d4a56a8fc0b2f4f91c216b1b1d5b231caa9abaaa38"
  license "MIT"

  # head "https://github.com/OGRECave/ogre-next.git", branch: "v2-3"

  depends_on "cmake" => :build
  depends_on "gz-plugin2" => :test
  depends_on "pkgconf" => :test

  depends_on "doxygen"
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

  patch do
    # Add simple implementation for STBIImageCodec::magicNumberToFileExt()
    url "https://github.com/OGRECave/ogre-next/commit/98c9095c6e288fceb59ccb3504d9127d88eb1b51.patch?full_index=1"
    sha256 "46a059f2c54641c1954f8c05c336fec71e711d1b80ff05fd9efa64feda8bccf2"
  end

  patch do
    # Fix loading of images in STBICodec
    url "https://github.com/OGRECave/ogre-next/commit/37d4876eb71c70b9eb3464e5b72c6e6d6be03232.patch?full_index=1"
    sha256 "9dcae0cc3a7d9d74c9724380340414399db9db974c77b6dc59c8302e0117488a"
  end

  patch do
    # Handle row padding correctly for 1, 2 and 4-channel images in STBICodec
    url "https://github.com/OGRECave/ogre-next/commit/96a3bb016b2c9b4f9cca9df1a65d619220e21d78.patch?full_index=1"
    sha256 "bcc23d665d530b678e87db628cfb759d141903cd91fe41edffef83a88914130e"
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
      "-DOGRE_CONFIG_ENABLE_STBI:BOOL=ON",
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
    p = version.patch.to_s
    lib.install Dir[lib/"OGRE-2.3/lib*.2.3.#{p}.dylib"]
    rm Dir[lib/"OGRE-2.3/lib*"]

    # Move plugins to subfolder
    (lib/"OGRE-2.3/OGRE").install Dir[lib/"OGRE-2.3/*.dylib"]

    # Restore lib symlinks
    Dir[lib/"lib*"].each do |l|
      (lib/"OGRE-2.3").install_symlink l => File.basename(l.sub(".2.3.#{p}", ""))
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
    # test building against API
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
