class IgnitionMsgs < Formula
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "http://gazebosim.org/distributions/ign-msgs/releases/ignition-msgs-0.3.0.tar.bz2"
  sha256 "d0a00e6eb74de9e5f4e3f269263a75dc664d8503af50734dbb8c92f79bf180e4"
  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-msgs/releases"
    sha256 "1831e5c3f48260756f0c4fc4cc6b00c57e09a6db64c572761d02335541403766" => :yosemite
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
