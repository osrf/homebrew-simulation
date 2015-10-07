class IgnitionTransport < Formula
  desc "Transport middleware for robotics"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport-0.9.0.tar.bz2"
  sha256 "3ff085d0398782e4e5edb48e86b6211eee38c56b415e000f7b02a398fba44895"
  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "dc0574caeb32ce35906d715947997ac0146239c8556cd8eb61b0a6ed63cfe293" => :yosemite
  end

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
