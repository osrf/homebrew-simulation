class IgnitionTransport3 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport3-3.0.1.tar.bz2"
  sha256 "c2b8dd5f391a30f1239893b51d4ea487fd47bfe12ccdb3876a83df192df666be"
  revision 8

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "026e29c0ecc4dfee72a5dbb87c176e457e3cb9475b28c6b1fe484b31afa48036" => :high_sierra
    sha256 "e34e5d4e76d3f80051772c38a4a571798361f6c7ed3cb424e817d8167acae294" => :sierra
    sha256 "f142839194381a6da9ca6dbe1a3c7c83238dc93245b12924fde9fea791e1b829" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :run

  depends_on "ignition-msgs0"
  depends_on "ignition-tools"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build
  depends_on "ossp-uuid"
  depends_on "zeromq"
  depends_on "cppzmq"

  patch do
    # Fix compiler warning
    url "https://bitbucket.org/ignitionrobotics/ign-transport/commits/3e5a61a5dadae573c23ba8185bb120cdbaff2d36/raw"
    sha256 "66570f0dec49e572c8687fc0819cefc5707ccb591e0a4923c48fbebe53b521c9"
  end

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
