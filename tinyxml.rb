require 'formula'

class Tinyxml < Formula
  url 'https://kforge.ros.org/rosrelease/viewvc/sourcedeps/tinyxml/tinyxml_2_6_2_stl_enabled.tar.gz'
  homepage 'http://www.grinninglizard.com/tinyxml/'
  sha1 'ed11ae63dd232414293ad060c0cb2c6746049883'
  version '2.6.2'

  # keg_only "To keep versions independant and not polute /usr/local."

  depends_on 'cmake' => :build

  def install
    ENV.universal_binary
    system "cmake . #{std_cmake_parameters}"
    system "make install"
  end
end
