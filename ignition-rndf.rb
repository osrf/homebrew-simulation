class IgnitionRndf < Formula
  desc "Ignition RNDF is a library for parsing RNDF road network files"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-rndf/releases/ignition-rndf-0.1.3.tar.bz2"
  sha256 "fc273bb1c8c6f5951a41ef3da56347c7fb50a678a8dcdad9569e66ef73a6fc5c"

  head "https://bitbucket.org/ignitionrobotics/ign-rndf", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "ignition-math3"
  depends_on "pkg-config" => :run

  patch do
    # Fix build with protobuf 2.6 (gazebo #1289)
    url "https://bitbucket.org/ignitionrobotics/ign-rndf/commits/17f2cbae25a82ef29804037cce2a5e3eebff5c6d/raw/"
    sha256 "283bf707cc6fe0dca33aded8c884adff81dcc81a38fb765eecaf9707b3bfed11"
  end

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
