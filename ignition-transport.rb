class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport-1.1.0.tar.bz2"
  sha256 "ed3617e7b1de58d3457f7cf79e6b70111f42a83e8f0c46dde834fce9516ffb7f"
  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    revision 2
    sha256 "3c59f42ce7a1f34a0d74cbce9d27e47f52e761dd0193f8e2b61aa48e0a458e34" => :yosemite
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :build

  depends_on "osrf/simulation/ignition-tools"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build
  depends_on "ossp-uuid"
  depends_on "zeromq"
  depends_on "cppzmq"

  patch do
    # Fix for ignition-tools library suffix
    url "https://bitbucket.org/ignitionrobotics/ign-transport/commits/69e61049a4b15a93625a7dde4838a71354ed9551/raw/"
    sha256 "7e3135aa4ef1f884c2c8ab476f40974b0c9b687896115140eab5d34d07c06125"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
