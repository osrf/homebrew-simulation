class IgnitionTransport3 < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport3-3.0.1.tar.bz2"
  sha256 "c2b8dd5f391a30f1239893b51d4ea487fd47bfe12ccdb3876a83df192df666be"
  revision 5

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "d0f5dc9491e815f98710d5fc6af76a3105358b896824ae4d953fa30a240a6c41" => :high_sierra
    sha256 "96f797c488028117dbbcd888a56037a13bab7727aa8c6e07bdda0e037e72e2ba" => :sierra
    sha256 "2fd741c74a88e14d3c447a916779678a4f1fc4d438e2b6454481f5521778243c" => :el_capitan
    sha256 "713f8e3d26d07b00ee41fed615795ee26914cb406181809a19fc6e5d6a9ef9ff" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :run

  depends_on "ignition-msgs"
  depends_on "ignition-tools"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build
  depends_on "ossp-uuid"
  depends_on "zeromq"
  depends_on "cppzmq"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include <ignition/transport.hh>
      int main() {
        ignition::transport::Node node;
        return 0;
      }
    EOS
    system "pkg-config", "ignition-transport3"
    cflags = `pkg-config --cflags ignition-transport3`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport3",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
