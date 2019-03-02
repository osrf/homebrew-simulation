class IgnitionTransport3 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport3-3.1.0.tar.bz2"
  sha256 "bc8ac5bbb1cfadda857f748ba6467f9512b37a2b8395121586c459166ae45703"
  revision 2

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases"
    cellar :any
    sha256 "cca7e9feb714fb3524090edabc9282aa59438602dc8667130f0502923a7a3921" => :mojave
    sha256 "95a7ba12bee7f75be226ca02ca5130232def56746e1cbf0a9d85d9195fbbff0f" => :high_sierra
    sha256 "87a0947afcd7a04fab5bad175e323a99dbea7b9bd2f5271511d81bab822883b3" => :sierra
    sha256 "577ca981fd7db206728084aeee723d250b45f23056eec309066b850b145c0221" => :el_capitan
  end

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
