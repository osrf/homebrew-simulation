class IgnitionMath4 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-math/get/cb9a1e95cff6.tar.gz"
  version "3.999.999~20170906~cb9a1e9"
  sha256 "833776f59a6c1be5806fef4d3445f9273bbee093a476fc85969ae4c362f446e2"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "f94b64eefadd1dd54cb0a31e18dc537e6dad8e17759aabee8784abfff09b3172" => :high_sierra
    sha256 "3085a48d816ae482f4605309ff216e1c8cdaab7ee67156c682433758f4def9e6" => :sierra
    sha256 "62f3ee3c57ca1c4d8925d2f431ba6390d1c115808c39330a01d98c6dec1c5dd3" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ignition-cmake0" => :build

  conflicts_with "ignition-math2", :because => "Symbols collision between the two libraries"
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
                   "-I#{include}/ignition/math4",
                   "-L#{lib}",
                   "-lignition-math4",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
