require "formula"

class Player < Formula
  homepage "http://playerstage.sourceforge.net"
  url "https://downloads.sourceforge.net/project/playerstage/Player/3.0.2/player-3.0.2.tar.gz"
  sha1 "34931ca57148db01202afd08fdc647cc5fdc884c"
  head "http://svn.code.sf.net/p/playerstage/svn/code/player/trunk"

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
