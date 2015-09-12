class IgnitionMsgs < Formula
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ignition/releases/ignition-msgs-0.1.0.tar.bz2"
  sha256 "bc225e0caa83d389a1186a8ff422e63b56093a3c44ad6bc8415dcf6b8b5e0b13"
  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "protobuf"
  depends_on "protobuf-c" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
