class Ogre22 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://www.ogre3d.org/"
  url "https://github.com/OGRECave/ogre-next/archive/312bf406a77244afe230930e67e3e5d52a119507.tar.gz"
  version "2.2.6+20211021~312bf40"
  sha256 "b9dbd84ef0c1731d0d1abc55499532358b9a9e5f0b3dc2b8e02ba76db0a112fd"
  license "MIT"
  revision 2

  # head "https://github.com/OGRECave/ogre-next.git", branch: "v2-2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sonoma: "e4aff5408f38e2ddbdda3b582f3d445de431e8723640c688574a4fe692e7f7c3"
    sha256 cellar: :any, sonoma:       "69e1b4dcd9ab083f9328a82930e544621b19afffa4101f4447ac2fc7da1ac2df"
    sha256 cellar: :any, ventura:      "39ee442113fbe0e76dd71f6cd9b90fb3cbb16de3a771c32d6fe12a0a4679dbdc"
    sha256 cellar: :any, monterey:     "0bd7b3f41e27834ff7ac6ae7c0711e18cb64bb0d1795903e98335e8618e3eb22"
    sha256 cellar: :any, big_sur:      "7d348ad79b4dc945b7305523d0826bb42d42747c921433fe792f4fe68d2e5191"
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
    # Fix for cmake3 and c++11
    url "https://github.com/scpeters/ogre-next/commit/3486b772b35b3e5f8cf6da5b7a41e6c195408d7d.patch?full_index=1"
    sha256 "30a60758401980260f3a5abdd6513505327028a983af9e911908b4f7da140625"
  end

  patch do
    # implement override for MetalTextureGpu::getCustomAttribute
    url "https://github.com/OGRECave/ogre-next/commit/b7187a55a9ad5ba65ed24d1c212d1749833923ac.patch?full_index=1"
    sha256 "38975001bfa903194565ed0bf411cf29857cd5b2f0f71a651d64543f610c4ff6"
  end

  # fix GL3+ compilation with Xcode 10
  # patch do
  #  url "https://github.com/OGRECave/ogre-next/commit/b00a880a4aea5492615ce8e3363e81631a53bb5c.patch?full_index=1"
  #  sha256 "8fe5beab9e50dfe1f0164e8dbffd20a79f5e9afe79802ab0ce29d8d83e4e0fe8"
  # end

  patch do
    # fix for m1 arch -- adapted from OGRECave/ogre-next@ff01338
    url "https://gist.githubusercontent.com/iche033/5685dcbb3efc14bb263718a91039bab8/raw/dd3ccbefda8abf1b9ff7b5a4898e3e63cbe06b4b/ogre2.2-m1-platform.patch"
    sha256 "edacb1992550c78e746d9bd545c8f5b278c2f987533349a0db56d7b13ebab480"
  end

  # fix for m1 arch -- adapted from OGRECave/ogre-next@23d8261
  patch do
    url "https://github.com/OGRECave/ogre-next/commit/23d82616a785f6aa26f58d5bf38a7114e2c00f88.patch?full_index=1"
    sha256 "ade27e55e7be5510f5eeb95f17c9ba90e61575ad610cc35f24179d061b1756a1"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"OGRE-2.2", target: lib),
      rpath(source: lib/"OGRE-2.2/OGRE", target: lib),
    ]
    cmake_args = [
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
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

    # Use a build folder
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
    inreplace (lib/"pkgconfig/OGRE-2.2.pc"), " -I${includedir}/OGRE", ""
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
    require "system_command"
    extend SystemCommand::Mixin
    # test plugins in subfolders
    ["libOgreMain", "libOgreOverlay", "libOgreSceneFormat", "OGRE/RenderSystem_Metal"].each do |plugin|
      p = lib/"OGRE-2.2/#{plugin}.dylib"
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
