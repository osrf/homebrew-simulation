require "formula"

class IgnitionMsgs < Formula
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url 'http://gazebosim.org/distributions/ignition/releases/ignition-msgs-0.1.0.tar.bz2'
  sha256 'bc225e0caa83d389a1186a8ff422e63b56093a3c44ad6bc8415dcf6b8b5e0b13'
  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => 'default', :using => :hg

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "osrf/simulation/protobuf" => 'c++11'
  depends_on "protobuf-c" => :build

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
