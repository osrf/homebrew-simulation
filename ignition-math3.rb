class IgnitionMath3 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math3-3.0.0.tar.bz2"
  sha256 "18ccb4e6190711ebc9c54d0563e14629d3161a4daef824294466d2af20a76796"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "d04babaebd30e8b8c2eb1bda07f5b45678bd1b48a06d6eaddcb64f1de51d5168" => :el_capitan
    sha256 "56579408f9a6838ecf67755aa31e377536364bb52ec34d2d91df91671db205ae" => :yosemite
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
