require 'formula'

class Ogre < Formula
  homepage 'http://www.ogre3d.org/'
  url 'https://downloads.sourceforge.net/project/ogre/ogre/1.7/ogre_src_v1-7-4.tar.bz2'
  version '1.7.4'
  sha1 'e989b96eacc2c66f8cf8a19dae6cfd962a165207'
  head 'https://bitbucket.org/sinbad/ogre', :branch => 'v1-9', :using => :hg

  depends_on 'boost'
  depends_on 'cmake' => :build
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'freetype'
  depends_on 'libzzip'
  depends_on 'tbb'
  depends_on :x11

  option 'with-cg'

  # https://gist.github.com/4237236
  patch do
    url 'https://gist.github.com/raw/4237236/e357f1b9fa8b26d02ed84f411d5b5eb7446c68c5/pkg_config_fix.patch'
    sha1 'f9100fef2823227803f14e1676818ed17a89e895'
  end if !build.head?
  patch do
    url 'https://gist.github.com/raw/4237236/57cb907304433cc0bb83fd332ff98a5789102b00/prevent_framework_apple.patch'
    sha1 '019c0c8f82ffd6c7dd258676c4f04b9881695e43'
  end if !build.head?
  patch do
    url 'https://gist.github.com/raw/4237236/31ae53cefdb693cb2fb81333178163a29f8cf7ca/osx_isystem.patch'
    sha1 'e750d6cb9f2b0123ef28dda4e024db98625fde76'
  end if !build.head?
  patch do
    url 'https://gist.github.com/raw/4237236/9c7df6689da4e0b358429692f6615f2707469f45/osx_linking.patch'
    sha1 '2855209c15422cc8df3110f9a0e32e084cd1e5b6'
  end if !build.head?
  patch do
    url 'https://gist.github.com/raw/4237236/d667813d5ee1e712e0ea8cc99df9a85da6141b1e/replace_pbxcp_with_ditto.patch'
    sha1 '3d2e4054643189273450245e15182f406125c94b'
  end if !build.head?
  patch do
    url 'https://gist.github.com/wjwwood/5672104/raw/bf69b4528b3090ad99a760029beb75b7aeb11248/fix_boost_linking.patch'
    sha1 '73d730e4fbc01ce06d9137a495b0a52488ca71e8'
  end if !build.head?
  patch do
    url 'https://gist.github.com/hgaiser/7346167/raw/3167c2fde153618e55b37f857ef4a90cc54ed2a3/ogre.patch'
    sha1 '6cf5fc081d291b7f9bc9ce3dd4019cc18b16b4b9'
  end if !build.head?
  patch do
    url 'https://gist.github.com/scpeters/568f5490a99aa9fc3eb7/raw/881b0f200ac218b7b976ade8f63e3792303c2a5e/ogre_find_freetype.diff'
    sha1 '0d9b58311b7a3abab0a0f230f45a5d8d1e285039'
  end if !build.head?

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_OSX_ARCHITECTURES='x86_64'",
    ]
    cmake_args << "-DOGRE_BUILD_PLUGIN_CG=OFF" if build.without? "cg"
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make install"
    end
  end
end
