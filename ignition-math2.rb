class IgnitionMath2 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.7.0.tar.bz2"
  sha256 "210e87958fc7ede75da02475e539b528536b87043a9f3df8ab0fb211bf3dc7ac"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "098ed08a8d2afb93cfb9e457dc4f82c70ec304f70b8dc375e174116c2c2bce58" => :el_capitan
    sha256 "5370ef2075a91d562cda50ea1c77ed02cf8efa3259f9fe811c909b44292e134f" => :yosemite
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
