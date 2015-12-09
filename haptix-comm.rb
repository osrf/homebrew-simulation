class HaptixComm < Formula
  desc "Haptix project communication API"
  homepage "http://gazebosim.org/haptix"
  url "http://gazebosim.org/distributions/haptix-comm/releases/haptix-comm-0.8.3.tar.bz2"
  sha256 "9970664a7c6686c6dc6f5e79d9d9a4f0cfbe0c6a9dbcf66237220b52ed0c6eb3"
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
