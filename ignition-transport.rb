class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport-1.4.0.tar.bz2"
  sha256 "bc612e9781f9cab81cc4111ed0de07c4838303f67c25bc8b663d394b40a8f5d4"
  revision 4

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport1", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "946ea884129efa3fc41ea4ba26d2b350129964f4a2db7635d5e6fecd454ef6a5" => :sierra
    sha256 "3fceab90ba1bfb7da79bf11b3df44315dbfb373809f61dcae67a8933ecc6b090" => :el_capitan
    sha256 "ff83f3fd94ec91e2ccf09f7aff2d3b59490c2713beb516eb7e9f3935b55ae722" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :run

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
    system "pkg-config", "ignition-transport1"
    cflags = `pkg-config --cflags ignition-transport1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport1",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
