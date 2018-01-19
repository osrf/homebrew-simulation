class IgnitionRndf0 < Formula
  desc "Ignition RNDF is a library for parsing RNDF road network files"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-rndf/get/7b8b1d2afa680424e4f53dbc7beafcdb88db50e0.tar.gz"
  sha256 "12f78a8534d812bc6248021d78961b1458715ec6f84edc2cce2a1c5fe01fc416"

  head "https://bitbucket.org/ignitionrobotics/ign-rndf", :branch => "default", :using => :hg

  # TODO(clalancette): temporarily disable bottles
  #bottle do
  #  root_url "http://gazebosim.org/distributions/ign-rndf/releases"
  #  cellar :any
  #  sha256 "12d534749f864a492063023fd8348af0b640fe8c06d0aac5ebd35f8a4fce79b8" => :high_sierra
  #  sha256 "14f140d27c57392fd2660ad82b4f2a4baec3b2c6b35b4e99bc03ff8cf3f76b1e" => :sierra
  #  sha256 "22e76615b5d8d00fd4dd8be897f92e96f51a0c4b468461609ec20112c1aee585" => :el_capitan
  #  sha256 "6e63700e9b48982728173c2670f38ff0fc981dc9faadb35c9633286f5b5529a9" => :yosemite
  #end

  depends_on "cmake" => :build
  depends_on "ignition-cmake0"
  depends_on "ignition-math3"
  depends_on "ignition-math4"
  depends_on "pkg-config" => :run

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
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
