class IgnitionRndf < Formula
  desc "Ignition RNDF is a library for parsing RNDF road network files"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-rndf/releases/ignition-rndf-0.1.5.tar.bz2"
  sha256 "b5abf08741690071759108b17b6179b7abba04e1088160d6c314e8d18343be15"

  head "https://bitbucket.org/ignitionrobotics/ign-rndf", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-rndf/releases"
    cellar :any
    sha256 "14f140d27c57392fd2660ad82b4f2a4baec3b2c6b35b4e99bc03ff8cf3f76b1e" => :sierra
    sha256 "b26f949e290714b996543613bb50ba35e6aeda77a990164c48c16cbc86db1b13" => :el_capitan
    sha256 "24b0c3ed5a42e43349f7fda556ff25eca43a2b2096a80da8a3e3511522a5e4d1" => :yosemite
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
