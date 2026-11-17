class Ogre112 < Formula
  desc "Scene-oriented 3D engine written in c++"
  homepage "https://ogrecave.github.io/ogre/"
  url "https://github.com/OGRECave/ogre/archive/refs/tags/v1.12.13.tar.gz"
  sha256 "b01ec30e7866b3140fc487eb828d92968d6aadc86254ad761a6bcac0f8b8a27f"
  license "MIT"

  keg_only "it installs the same headers and pkg-config files as ogre1.9"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :test

  depends_on "freetype"
  depends_on "libzzip"

  uses_from_macos "zlib"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"OGRE", target: lib),
    ]
    cmake_args = [
      "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}",
      # OGRE 1.12 requires CMake 3.3, CMake 4 removed compatibility with < 3.5
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
      # OGRE 1.12 defaults CMAKE_OSX_ARCHITECTURES to x86_64 when it is empty
      "-DCMAKE_OSX_ARCHITECTURES=#{Hardware::CPU.arch}",
      # Use the dependencies from Homebrew instead of downloading them
      "-DOGRE_BUILD_DEPENDENCIES=OFF",
      # SDL2 and Qt5 are only used by the samples and Bites, which are not
      # built. Homebrew's SDL2Config.cmake (sdl2-compat) also fails to load in
      # OGRE's configure: it calls set_package_properties without including
      # FeatureSummary.
      "-DCMAKE_DISABLE_FIND_PACKAGE_SDL2=ON",
      "-DCMAKE_DISABLE_FIND_PACKAGE_Qt5=ON",
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      # Render systems and components used by gz-rendering
      "-DOGRE_BUILD_RENDERSYSTEM_GL=ON",
      "-DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=ON",
      "-DOGRE_BUILD_RENDERSYSTEM_GLES2=OFF",
      "-DOGRE_BUILD_RENDERSYSTEM_METAL=OFF",
      "-DOGRE_BUILD_COMPONENT_RTSHADERSYSTEM=ON",
      "-DOGRE_BUILD_COMPONENT_TERRAIN=ON",
      "-DOGRE_BUILD_COMPONENT_PAGING=ON",
      "-DOGRE_BUILD_COMPONENT_OVERLAY=ON",
      # dear imgui is downloaded at configure time
      "-DOGRE_BUILD_COMPONENT_OVERLAY_IMGUI=OFF",
      "-DOGRE_BUILD_COMPONENT_BITES=OFF",
      "-DOGRE_BUILD_COMPONENT_CSHARP=OFF",
      "-DOGRE_BUILD_COMPONENT_JAVA=OFF",
      "-DOGRE_BUILD_COMPONENT_PYTHON=OFF",
      # Image codecs: stb_image is bundled, no FreeImage or OpenEXR
      "-DOGRE_BUILD_PLUGIN_STBI=ON",
      "-DOGRE_BUILD_PLUGIN_FREEIMAGE=OFF",
      "-DOGRE_BUILD_PLUGIN_EXRCODEC=OFF",
      "-DOGRE_BUILD_PLUGIN_ASSIMP=OFF",
      "-DOGRE_BUILD_PLUGIN_CG=OFF",
      "-DOGRE_BUILD_PLUGIN_DOT_SCENE=OFF",
      "-DOGRE_BUILD_SAMPLES=OFF",
      "-DOGRE_BUILD_TESTS=OFF",
      "-DOGRE_BUILD_TOOLS=OFF",
      "-DOGRE_INSTALL_DOCS=OFF",
      "-DOGRE_INSTALL_SAMPLES=OFF",
    ]
    cmake_args.concat std_cmake_args

    system "cmake", "-S", ".", "-B", "build", *cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    %w[RenderSystem_GL RenderSystem_GL3Plus Plugin_ParticleFX
       Plugin_BSPSceneManager Plugin_OctreeSceneManager Codec_STBI].each do |plugin|
      assert_path_exists lib/"OGRE/#{plugin}.dylib"
    end

    (testpath/"test.cpp").write <<~CPP
      #include <Ogre.h>
      #include <OgreOverlaySystem.h>
      #include <OgrePaging.h>
      #include <OgreRTShaderSystem.h>
      #include <OgreTerrain.h>
      #include <iostream>
      int main()
      {
        Ogre::Vector3 v(1, 2, 3);
        std::cout << OGRE_VERSION_MAJOR << "." << OGRE_VERSION_MINOR << "."
                  << OGRE_VERSION_PATCH << std::endl;
        return v.length() > 0 ? 0 : 1;
      }
    CPP
    modules = %w[OGRE OGRE-Overlay OGRE-Paging OGRE-RTShaderSystem OGRE-Terrain]
    flags = shell_output("pkgconf --cflags --libs #{modules.join(" ")}").chomp.split
    system ENV.cxx, "test.cpp", "-std=c++11", *flags, "-Wl,-rpath,#{lib}", "-o", "test"
    assert_equal version.to_s, shell_output("./test").strip
    assert_equal version.to_s, shell_output("pkgconf --modversion OGRE").strip
  end
end
