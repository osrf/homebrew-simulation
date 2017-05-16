class IgnitionMath3 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math3-3.2.0.tar.bz2"
  sha256 "742bc95f95ba2f89913f25e7272bb4f0a202de95e4567cda37fe078d3a2702a1"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "e65b8d0610e2d7ae638734ffed48958a21f76e91aad843b5109e7e91a994495e" => :sierra
    sha256 "62f3ee3c57ca1c4d8925d2f431ba6390d1c115808c39330a01d98c6dec1c5dd3" => :el_capitan
    sha256 "360b5673f882a817cb0e576b2778c8665d27f0671d34eaa188f30873221da058" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build

  conflicts_with "ignition-math2", :because => "Symbols collision between the two libraries"

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
                   "-I#{include}/ignition/math3",
                   "-L#{lib}",
                   "-lignition-math3",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
