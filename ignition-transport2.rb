class IgnitionTransport2 < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-transport/get/94f4417.tar.gz"
  version "2.0.0-20160609-94f4417"
  sha256 "333b5895bbe15d69cc2dcdcbd604b4e99bf1933fb669e38dd6d23d9cbfcdec7e"
  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "2eeed4b4c406088d9dafd57de13a4b48096d70afbf35d9aa86ca0c7dfc15d4ea" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :run

  depends_on "osrf/simulation/ignition-msgs"
  depends_on "osrf/simulation/ignition-tools"
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
    system "pkg-config", "--modversion", "ignition-transport2"
  end
end
