class IgnitionMath2 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.9.0.tar.bz2"
  sha256 "4c007af9efe42908a240895b2a9bcb5c4e570ac0e4ed152c4edd724f86171931"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "2f48914f690352add2d2fce6cd22a260e43ea54a02da386bef4bba1470bf7750" => :high_sierra
    sha256 "5e313d779a496c3963d57495723506400fc1d71bf831d3cfff0f9e9d09bb46fc" => :sierra
    sha256 "59eb583fb73e998510a3571a794e96b57a49b68ddca4cd03119d748c6d51d655" => :el_capitan
    sha256 "401ecbcc6c53af2ba8161790115a0df3cefbe393cafa72358fd92441bccdb633" => :yosemite
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
