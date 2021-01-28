class IgnitionRndf0 < Formula
  desc "Ignition RNDF is a library for parsing RNDF road network files"
  homepage "https://ignitionrobotics.org"
  url "https://github.com/ignitionrobotics/ign-rndf/archive/45652bceabce1ea1630b41623f56560f10674343.tar.gz"
  sha256 "ae108308d8a7b4dddfd3a5d23eb3d8a844e1760bf01cb3066cdd45570cf6c26f"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-rndf.git", branch: "master"

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
    cflags = `pkg-config --cflags ignition-rndf0`.split
    libs   = `pkg-config --libs ignition-rndf0`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *libs,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
