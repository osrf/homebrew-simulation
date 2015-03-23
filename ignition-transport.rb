require "formula"

class IgnitionTransport < Formula
  homepage "http://ignitionrobotics.org"
  url 'http://gazebosim.org/distributions/ignition/releases/ignition-transport-0.7.0.tar.bz2'
  sha1 '3a6e6a8f9edd60fd18fa4c4d3dcfe71acfd2d807'
  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => 'default', :using => :hg

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :build

  depends_on "protobuf"
  depends_on "protobuf-c" => :build
  depends_on "ossp-uuid"
  depends_on "zeromq"
  depends_on "bertjwregeer/compat/cppzmq"

  def install
    cmake_args = std_cmake_args.select { |arg| arg.match(/CMAKE_BUILD_TYPE/).nil? }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
