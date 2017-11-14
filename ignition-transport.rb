class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport-1.4.0.tar.bz2"
  sha256 "bc612e9781f9cab81cc4111ed0de07c4838303f67c25bc8b663d394b40a8f5d4"
  revision 5

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport1", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "93f560b5c818acf2d2e6c507ca8dbcd18edd9c405cac85bffc16141f53db2d2b" => :high_sierra
    sha256 "e52158becd468f78ffe3910182a2f1cfe4f8ec8c388aa16ac338bbb59fad61af" => :sierra
    sha256 "e89232e0097fd2f4f1b4a454d49bfd46426d751a2a6b26cdb6744df72d2c5b20" => :el_capitan
    sha256 "6f4507102b03c5d68eb7e2520d14025ba9fa36d642fb44ab919e95a0c0ff97df" => :yosemite
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
