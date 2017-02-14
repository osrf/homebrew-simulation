class IgnitionMath2 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.8.0.tar.bz2"
  sha256 "af3a92bd6b39627ac391fdd0b30b841964256ea4a26238d2c0e4a645b134fa83"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "9af8a544e6bcff04ac7f3ab62e26fdee9126d5538c1560fc2702e97b18a4060b" => :el_capitan
    sha256 "5370ef2075a91d562cda50ea1c77ed02cf8efa3259f9fe811c909b44292e134f" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build

  conflicts_with "ignition-math3", :because => "Symbols collision between the two libraries"

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
