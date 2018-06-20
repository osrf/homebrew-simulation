class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport-1.4.0.tar.bz2"
  sha256 "bc612e9781f9cab81cc4111ed0de07c4838303f67c25bc8b663d394b40a8f5d4"
  revision 6

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport1", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "0716a01ab56b6f9c202066f517f4ebbac140fe1ed019ddc64867c91c06e97fe1" => :high_sierra
    sha256 "1ccac59565b9dd613b6084cc31468b78d7312cb5777ae5f37bf891d032a02389" => :sierra
    sha256 "c6240d3bd4f33a1d55ea359bc76b0900681fc80011d108232958d07f25108b3a" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]

  depends_on "cppzmq"
  depends_on "ignition-tools"
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build
  depends_on "zeromq"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
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
