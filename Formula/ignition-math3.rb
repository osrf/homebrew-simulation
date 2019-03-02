class IgnitionMath3 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-math/releases/ignition-math3-3.3.0.tar.bz2"
  sha256 "97bb7f20b64c9a281873ac6fd02932390ca9a0d5709256e671c4db4221a8e051"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/ign-math/releases"
    cellar :any
    sha256 "958ed00cd402ba76a8095adb3aa804243b553b126b60882cd7162dc60d6098d1" => :mojave
    sha256 "79f35d471b53743a1a8ad5d40d64014ef732247312c8b8cb22ce83b40783e945" => :high_sierra
    sha256 "34c194270aa0e1dbf44a11e18313ce986ef7654745e1d01689a73b7a53507720" => :sierra
    sha256 "4f35a563ed082a2c3e72be81b574495eb4d430541bce5323526a4faf6356455c" => :el_capitan
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
    (testpath/"test.cpp").write <<-EOS
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
