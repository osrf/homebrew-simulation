class IgnitionMsgs < Formula
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ign-msgs/releases/ignition-msgs-0.3.0.tar.bz2"
  sha256 "d0a00e6eb74de9e5f4e3f269263a75dc664d8503af50734dbb8c92f79bf180e4"
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
