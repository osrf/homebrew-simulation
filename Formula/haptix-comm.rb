class HaptixComm < Formula
  desc "Haptix project communication API"
  homepage "http://gazebosim.org/haptix"
  url "https://osrf-distributions.s3.amazonaws.com/haptix-comm/releases/haptix-comm-0.9.0.tar.bz2"
  sha256 "d495f65e401fc9e3c8fcbdded347313287c2de55f1605f6b76d02a26b893c08d"
  license "Apache-2.0"
  head "https://github.com/osrf/haptix-comm.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :build
  depends_on "protobuf-c" => :build

  depends_on "cppzmq"
  depends_on "ignition-transport"
  depends_on "protobuf"
  depends_on "zeromq"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
