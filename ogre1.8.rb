require 'formula'

class Ogre18 < Formula
  homepage 'http://www.ogre3d.org/'
#  url 'http://downloads.sourceforge.net/project/ogre/ogre/1.7/ogre_src_v1-7-4.tar.bz2'
#  version '1.7.4'
#  sha1 'e989b96eacc2c66f8cf8a19dae6cfd962a165207'

  url 'http://downloads.sourceforge.net/project/ogre/ogre/1.8/1.8.1/ogre_src_v1-8-1.tar.bz2'
  version '1.8.1'
  sha1 'd6153cacda24361a81e7d0a6bf9aa641ad9dd650'

#  url 'https://bitbucket.org/sinbad/ogre/get/v1-9-0.tar.gz'
#  version '1.9.0'
#  sha1 'dd1c0a27ff76a34d3c0daf7534ab9cd16e399f86'

  head 'https://bitbucket.org/sinbad/ogre', :branch => 'v1-8', :using => :hg

  patch do
    url 'https://gist.githubusercontent.com/NikolausDemmel/dad2dec7e52bed7c1bec/raw/f1bde5b93aa3f13780f7494f84dd3c76dd57c360/fixogre1.8.patch'
    sha1 '0f9f15bfcb2296a7a12017acd2668594958bffe7'
  end

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
      "-DOGRE_FULL_RPATH:BOOL=FALSE",
      "-DOGRE_BUILD_DOCS:BOOL=TRUE",
      "-DOGRE_INSTALL_DOCS:BOOL=TRUE",
      "-DOGRE_BUILD_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES:BOOL=FALSE",
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=FALSE",
      "-DOGRE_CONFIG_ENABLE_LIBCPP_SUPPORT=ON",
    ]
    cmake_args << "-DOGRE_BUILD_PLUGIN_CG=OFF" unless build.include? "with-cg"
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make install"
    end

    Dir.glob(lib/"OGRE/*.dylib") do |path|
      filename = File.basename(path)
      symlink path, lib/"OGRE/lib#{filename}"
    end

  end
end
