class IgnitionMath2 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.2.3.tar.bz2"
  sha256 "0a94939e9f6522002d243ce9adc74262f8f3c27b9213386d4c78438620098d94"
  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "e5602b69f3d178c4b8835c7b78b712103bb3342e0ccad6985bc04431c9792630" => :yosemite
  end

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
