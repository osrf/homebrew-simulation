class IgnitionMath2 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.6.0.tar.bz2"
  sha256 "5224991ea409346be95c68451934db93d74e2fac9c0b39d961049cfb015696b4"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    #root_url "http://gazebosim.org/distributions/ign-math/releases"
    root_url "http://px4-travis.s3.amazonaws.com/toolchain/bottles"
    cellar :any
    sha256 "9d30668a239bae88f66267d74224b5df8b8d2fd6fd348e2b0401335759c910f9" => :el_capitan
    sha256 "d18ff2dad5ecf0abb515ef8246ad21d9b21def2dc06ffb7a8f81112ea9f22fc2" => :yosemite
    sha256 "234032f265c86e508c8ca8019547de75c2f4bac5440f4726faf32cf48b28e729" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include "ignition/math/SignalStats.hh"
      int main() {
        ignition::math::SignalMean mean;
        mean.InsertData(1.0);
        mean.InsertData(-1.0);
        return static_cast<int>(mean.Value());
      }
    EOS
    system ENV.cc, "test.cpp",
                   "--std=c++11",
                   "-I#{include}/ignition/math2",
                   "-L#{lib}",
                   "-lignition-math2",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
