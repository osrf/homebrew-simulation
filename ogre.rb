require 'formula'

class Ogre < Formula
  homepage 'http://www.ogre3d.org/'
  url 'https://sourceforge.net/projects/ogre/files/ogre/1.7/ogre_src_v1-7-4.tar.bz2'
  version '1.7.4'
  sha1 'e989b96eacc2c66f8cf8a19dae6cfd962a165207'

  depends_on 'boost'
  depends_on 'cmake' => :build
  depends_on 'doxygen'
  depends_on 'freeimage'
  depends_on 'freetype'
  depends_on 'libzzip'
  depends_on 'tbb'
  depends_on :x11

  def patches
    # https://gist.github.com/4237236
    [
      "https://gist.github.com/raw/4237236/e357f1b9fa8b26d02ed84f411d5b5eb7446c68c5/pkg_config_fix.patch",
      "https://gist.github.com/raw/4237236/57cb907304433cc0bb83fd332ff98a5789102b00/prevent_framework_apple.patch",
      "https://gist.github.com/raw/4237236/31ae53cefdb693cb2fb81333178163a29f8cf7ca/osx_isystem.patch",
      "https://gist.github.com/raw/4237236/9c7df6689da4e0b358429692f6615f2707469f45/osx_linking.patch",
      "https://gist.github.com/raw/4237236/d667813d5ee1e712e0ea8cc99df9a85da6141b1e/replace_pbxcp_with_ditto.patch",
      "https://gist.github.com/wjwwood/5672104/raw/bf69b4528b3090ad99a760029beb75b7aeb11248/fix_boost_linking.patch"
    ]
  end

  def install
    ENV.m64

    cmake_args = [
      "-DCMAKE_OSX_ARCHITECTURES='x86_64'",
      "-DOGRE_BUILD_PLUGIN_CG=OFF"
    ]
    cmake_args.concat(std_cmake_args)
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
      system "make install"
    end
  end

  def test
    system "false"
  end
end
