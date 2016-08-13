class IgnitionMsgs < Formula
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ign-msgs/releases/ignition-msgs-0.5.0.tar.bz2"
  sha256 "d27c4dacce646ef013965742ec2fea207677937f3e3264870fe64d112e655b09"
  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-msgs/releases"
    sha256 "d35dbfa3ae63fb0e2d81fc403ba2d7c896c52bd6961e53707a8fba2ea4434204" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "ignition-math2"
  depends_on "ignition-tools" => :recommended
  depends_on "pkg-config" => :run
  depends_on "protobuf"
  depends_on "protobuf-c" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "pkg-config", "--modversion", "ignition-msgs0"
  end
end
