class IgnitionRndf < Formula
  desc "Ignition RNDF is a library for parsing RNDF road network files"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-rndf/releases/ignition-rndf-0.1.5.tar.bz2"
  sha256 "b5abf08741690071759108b17b6179b7abba04e1088160d6c314e8d18343be15"

  head "https://bitbucket.org/ignitionrobotics/ign-rndf", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-rndf/releases"
    cellar :any
    sha256 "12d534749f864a492063023fd8348af0b640fe8c06d0aac5ebd35f8a4fce79b8" => :high_sierra
    sha256 "14f140d27c57392fd2660ad82b4f2a4baec3b2c6b35b4e99bc03ff8cf3f76b1e" => :sierra
    sha256 "22e76615b5d8d00fd4dd8be897f92e96f51a0c4b468461609ec20112c1aee585" => :el_capitan
    sha256 "6e63700e9b48982728173c2670f38ff0fc981dc9faadb35c9633286f5b5529a9" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "ignition-math3"
  depends_on "pkg-config" => :run

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
    #include "ignition/rndf/UniqueId.hh"
    #include "ignition/rndf/RNDFNode.hh"

    int main() {
      int segmentId = 1;
      int laneId = 2;
      int waypointId = 3;
      ignition::rndf::UniqueId id(segmentId, laneId, waypointId);
      ignition::rndf::RNDFNode rndfNode(id);
    }
    EOS
    system "pkg-config", "ignition-rndf0"
    cflags = `pkg-config --cflags ignition-rndf0`.split(" ")
    libs   = `pkg-config --libs ignition-rndf0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *libs,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
