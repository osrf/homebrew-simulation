class IgnitionTransport2 < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport2-2.1.0.tar.bz2"
  sha256 "f1190ee6a880962b9083328efcaf4c8fe4e9f00504da4432cde69820edbc212e"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "3ebd085bf4164600af12b478e48279e37417c42ccdd86395ba4eb31c91dafc96" => :el_capitan
    sha256 "3ebd085bf4164600af12b478e48279e37417c42ccdd86395ba4eb31c91dafc96" => :yosemite
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
    system "pkg-config", "ignition-transport2"
    cflags = `pkg-config --cflags ignition-transport2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport2",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
