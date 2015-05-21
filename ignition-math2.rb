class IgnitionMath2 < Formula
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.0.3.tar.bz2"
  sha256 "27cf03eaf998f5d153b749372d8e968ce13e6fa481611688f0deb8935a2be5fa"
  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
