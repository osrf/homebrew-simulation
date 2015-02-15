require 'formula'

class Ogre19 < Formula
  homepage 'http://www.ogre3d.org/'

  stable do
    url 'https://bitbucket.org/sinbad/ogre/get/v1-9-0.tar.gz'
    version '1.9.0'
    sha1 'dd1c0a27ff76a34d3c0daf7534ab9cd16e399f86'

    patch do
      url 'https://gist.githubusercontent.com/NikolausDemmel/2b11d1b49b35cd27a102/raw/3af6b11889a90d7e35bb90cdb34c46ea8334eaf3/fix-1.9.0-release.diff'
      sha1 '9ad217fc33690f76fd857ba49c3840715d4f3527'
    end

    patch do
      # COMMENT @NikolausDemmel 2015-02-15
      # it seems that in the latest v1-9 branch there is a different fix for this:
      # https://bitbucket.org/sinbad/ogre/src/f40744b1106a0ce3b2cd0eadfd05bcf344f28167/RenderSystems/GL/src/OSX/OgreOSXCocoaWindow.mm?at=v1-9#cl-285
      # i.e. this patch is possibly obsolete
      url 'https://gist.githubusercontent.com/hgaiser/9ed14de3d776cd34100e/raw/38c7a88cab9067e88a21f1386fbb8ac1aaeed8ac/window.patch'
      sha1 'c520d0641183bb275a0b29ef6188353bc2ba6217'
    end
  end

  devel do
    url 'https://bitbucket.org/sinbad/ogre/get/v1-9.tar.bz2'
    version '1.9.1-devel'
    sha1 'aa9b0c6d371802e0535515758e88c4893045cd5f'

    patch do
      url 'https://gist.github.com/NikolausDemmel/2b11d1b49b35cd27a102/raw/bf4a4d16020821218f73db0d56aa111ab2fde679/fix-1.9-HEAD.diff'
      sha1 '90bef44c2a821bba3254c011b0aa0f5ecedeb788'
    end
  end

  #head 'https://bitbucket.org/sinbad/ogre', :using => :hg
  #patch :DATA

  depends_on 'boost'
  depends_on 'cmake' => :build
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'freetype'
  depends_on 'libzzip'
  depends_on 'tbb'
  depends_on :x11

  option 'with-cg'

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_OSX_ARCHITECTURES='x86_64'",
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF",
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_BUILD_DOCS:BOOL=FALSE",
      "-DOGRE_INSTALL_DOCS:BOOL=FALSE",
      "-DOGRE_BUILD_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=FALSE",
    ]
    cmake_args << "-DOGRE_BUILD_PLUGIN_CG=OFF" unless build.include? "with-cg"
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make install"
    end

    # Reference of where debian puts files:
    # https://packages.debian.org/jessie/amd64/libogre-1.9-dev/filelist
    # https://packages.debian.org/jessie/amd64/libogre-1.9.0/filelist

    # FIXME: for now we build with doc and samples OFF, so config files, media
    #        and docs are not present

    # remove config files from bin directory
#     (share/'OGRE/config').install Dir[bin/"macosx/*.cfg"]
#     rmdir bin/"macosx"
#
#     (share/"OGRE/").install prefix/"Media"
#     rmdir prefix/"Media"
#
#     (doc/"OGRE").install Dir[prefix/"Docs/*"]
#     rmdir prefix/"Docs"

    # Put these cmake files where Debian puts them
    (share/"OGRE/cmake/modules").install Dir[prefix/"CMake/*.cmake"]
    rmdir prefix/"CMake"

    # This is necessary because earlier versions of Ogre seem to have created
    # the plugins with "lib" prefix and software like "rviz" now has Mac
    # specific code that looks for the plugins with "lib" prefix. Hence we add
    # symlinks with the "lib" prefix manually, but their use is deprecated.
    Dir.glob(lib/"OGRE/*.dylib") do |path|
      filename = File.basename(path)
      symlink path, lib/"OGRE/lib#{filename}"
    end

  end
end
