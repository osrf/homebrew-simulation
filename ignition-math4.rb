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
    sha256 "e803940114a1ac046bd1f7712f94b02b842ec1b13085494b09d6b368bf55816d" => :high_sierra
    sha256 "8421764057cdb8b8c21bb6a9b5f724a80ffd3442593e0773a7de23fcb20e255a" => :sierra
    sha256 "585fe16006871062eff1ccfaccf87809b76bfd356415cdffe70902933c948437" => :el_capitan
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
