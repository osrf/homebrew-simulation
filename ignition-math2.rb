class IgnitionMath2 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.2.2.tar.bz2"
  sha256 "c9569c764ac74699ca084dc170f83270d52eab66b1ef23cedb94a4e8f5651fd7"
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
