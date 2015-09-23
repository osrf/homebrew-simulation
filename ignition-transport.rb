class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport-0.8.1.tar.bz2"
  sha256 "f5ec419a47a730391a9ed7a137ec5241edafdd39c2215d81f3e5f7963c7cb67a"
  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :build

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
    system "false"
  end
end
