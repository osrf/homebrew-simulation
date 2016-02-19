class HaptixComm < Formula
  desc "Haptix project communication API"
  homepage "http://gazebosim.org/haptix"
  url "http://gazebosim.org/distributions/haptix-comm/releases/haptix-comm-0.9.0~pre1.tar.bz2"
  sha256 "f89e232fc54b4bfa2b3c6c783e4ff5b3f4725e182c76f1a4648a1d2d7442247b"
  head "https://bitbucket.org/osrf/haptix-comm", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :build

  depends_on "ignition-transport"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build
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
