class IgnitionMath3 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math3-3.1.0.tar.bz2"
  sha256 "aeece783a753fbf6b86bd3a7a02529137953bcef5b8be11c740475cc80528448"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "9a6e8a2ea6f981b43b90286fbe00363775390078b87e10b4004b2d9b60e8e631" => :el_capitan
    sha256 "683ef486529a229b568d5e744f4b8143228dd72ff3d847243bdf0241d07305dd" => :yosemite
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
