class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport-1.4.0.tar.bz2"
  sha256 "bc612e9781f9cab81cc4111ed0de07c4838303f67c25bc8b663d394b40a8f5d4"
  revision 8

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport1", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "a4bfadafc525fe98ee3d88cfbd8426ab4c83d552d80a89e4262d5a2e497acd9d" => :mojave
    sha256 "6ac9455fa402ea41b3b8de932d4fb002eaf8f467182339c9f659a98c3e0c6623" => :high_sierra
    sha256 "00051c608906752131f98e4c7495aa15d02f4afba533e4a62936c402fa099d78" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]

  depends_on "protobuf-c" => :build
  depends_on "cppzmq"
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
