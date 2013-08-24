require 'formula'

class Tinyxml < Formula
  url 'http://downloads.sourceforge.net/project/tinyxml/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz'
  homepage 'http://www.grinninglizard.com/tinyxml/'
  sha1 'cba3f50dd657cb1434674a03b21394df9913d764'

  depends_on 'cmake' => :build

  # The first two patches are taken from the debian packaging of tinyxml.
  #   The first patch enforces use of stl strings, rather than a custom string type.
  #   The second patch is a fix for incorrect encoding of elements with special characters
  #   originally posted at http://sourceforge.net/p/tinyxml/patches/51/
  # The third patch adds a CMakeLists.txt file to simplify build and install.
  def patches
    [
      'http://patch-tracker.debian.org/patch/series/dl/tinyxml/2.6.2-2/enforce-use-stl.patch',
      'http://patch-tracker.debian.org/patch/series/dl/tinyxml/2.6.2-2/entity-encoding.patch',
      'https://gist.github.com/scpeters/6325123/raw/cfb079be67997cb19a1aee60449714a1dedefed5/tinyxml_CMakeLists.patch'
    ]
  end

  def install
    ENV.universal_binary
    system "cmake . #{std_cmake_parameters}"
    system "make install"
  end
end
