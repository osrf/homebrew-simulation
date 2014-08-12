require "formula"

class IgnitionTransport < Formula
  homepage "http://ignitionrobotics.org"
  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => 'transport_0.3.0', :using => :hg

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :build

  depends_on "osrf/simulation/protobuf" => "c++11"
  depends_on "protobuf-c" => :build
  depends_on "osrf/simulation/ignition-msgs" => :build
  depends_on "ossp-uuid"
  depends_on "zeromq"
  depends_on "czmq" => "HEAD"
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
