class IgnitionMath4 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math4-4.0.0~pre1.tar.bz2"
  version "4.0.0~pre1"
  sha256 "9e4255bbeb72f1e2186a3ac5d665d10a7f46fddf881ab2d344874f0b14791590"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "f13375352a730c589fc500455fb702e4c9ea28633adec5f24677cd6ed280ecc6" => :high_sierra
    sha256 "8421764057cdb8b8c21bb6a9b5f724a80ffd3442593e0773a7de23fcb20e255a" => :sierra
    sha256 "af9c9d9427b0a2425dd62c077967a2dfc128b9ddda98bb318cc631b9ed2a7a44" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ignition-cmake0"

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
