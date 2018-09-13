class IgnitionTransport3 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport3-3.1.0.tar.bz2"
  sha256 "bc8ac5bbb1cfadda857f748ba6467f9512b37a2b8395121586c459166ae45703"
  revision 2

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "bba78c2638152623e8b7adbb54bb7197d88ea6b5bb35989e6918fe1fd70353cf" => :high_sierra
    sha256 "7420cb7c2aec0c680bfa348f39a0e3af5e919cd1cfdaaccea92f6443a856080d" => :sierra
    sha256 "b6238eb3b4dbd398b6046bcd197f02b32e3ea13b5c68718beaa625606011e061" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]

  depends_on "cppzmq"
  depends_on "ignition-msgs0"
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
