class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport-1.4.0.tar.bz2"
  sha256 "bc612e9781f9cab81cc4111ed0de07c4838303f67c25bc8b663d394b40a8f5d4"
  revision 9

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport1", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "28742a2f609a344ef1ee03d904dfd8a614c6afe91ba235e88fb21e3dfa71ed09" => :mojave
    sha256 "e4dc45f24ea827606804f171706b8bb5243ca7df4a0c984b6f209d6c5eecbff8" => :high_sierra
    sha256 "53ba2f727b47dc949a8e9d0280690b8f7e1747c7dd7e767c1266951f348bff6b" => :sierra
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
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
