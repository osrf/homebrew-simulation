class IgnitionMath2 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math2-2.9.0.tar.bz2"
  sha256 "4c007af9efe42908a240895b2a9bcb5c4e570ac0e4ed152c4edd724f86171931"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "2ae16a6900abb6406c6652bae192735da46229c54c254c83153e176296cc587f" => :high_sierra
    sha256 "4f98153b78da9ff94d4b5f3ee198348a33b874950d27ccd8e31635b66547ee91" => :sierra
    sha256 "56ab32955316309781891c9153d174e740a6df7acaf15fbe7d1e9759e386d908" => :el_capitan
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
