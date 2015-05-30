class IgnitionMath2 < Formula
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.1.1.tar.bz2"
  sha256 "629f5e65af960e6d6773062984b0c0c6c977c7d2245eba9979db17a9f17058fa"
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
