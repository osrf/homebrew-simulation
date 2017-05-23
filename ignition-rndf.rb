class IgnitionRndf < Formula
  desc "Ignition RNDF is a library for parsing RNDF road network files"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-rndf/releases/ignition-rndf-0.1.4.tar.bz2"
  sha256 "1fc7dcea88f188c6d244d75a4b04ab61c0d3cb0cfa26e87ca9dd6670d6976f8d"

  head "https://bitbucket.org/ignitionrobotics/ign-rndf", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-rndf/releases"
    cellar :any
    sha256 "82793d8a0f9f9cbb404ce4853afd97c640884e3ec9c10e4f0dfb628c74859fe8" => :sierra
    sha256 "5a5af739d9582ea9bc6f924cc90100765736f42aedbae64f0c42259238893b05" => :el_capitan
    sha256 "6a333774fbbb3d17ff0fb54287f4ffc0a0c17011fe8e009ca29a5a5545f4464f" => :yosemite
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
