class IgnitionRndf0 < Formula
  desc "Ignition RNDF is a library for parsing RNDF road network files"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-rndf/get/7b8b1d2afa680424e4f53dbc7beafcdb88db50e0.tar.gz"
  sha256 "12f78a8534d812bc6248021d78961b1458715ec6f84edc2cce2a1c5fe01fc416"

  head "https://github.com/ignitionrobotics/ign-rndf", :branch => "master"

  depends_on "cmake" => :build
  depends_on "ignition-cmake0"
  depends_on "ignition-math3"
  depends_on "ignition-math4"
  depends_on "pkg-config"

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
