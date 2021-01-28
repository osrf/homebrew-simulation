class IgnitionTransport2 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport2-2.1.0.tar.bz2"
  sha256 "f1190ee6a880962b9083328efcaf4c8fe4e9f00504da4432cde69820edbc212e"
  license "Apache-2.0"
  revision 6

  head "https://github.com/ignitionrobotics/ign-transport.git", branch: "ign-transort2"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cppzmq"
  depends_on "ignition-msgs0"
  depends_on "ignition-tools"
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
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
    system "pkg-config", "ignition-transport2"
    cflags = `pkg-config --cflags ignition-transport2`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport2",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
