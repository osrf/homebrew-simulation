class IgnitionTransport3 < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport3-3.0.1.tar.bz2"
  sha256 "c2b8dd5f391a30f1239893b51d4ea487fd47bfe12ccdb3876a83df192df666be"
  revision 6

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "d0f5dc9491e815f98710d5fc6af76a3105358b896824ae4d953fa30a240a6c41" => :high_sierra
    sha256 "0653994999fce80cae9bb4fe9c92639c5fa356dcb0f3b02ab964f177a525e607" => :sierra
    sha256 "0c53ebf8af7bc7caa64806e715d4f06341e08ed52bd02c039a299569fb57c5b5" => :el_capitan
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
