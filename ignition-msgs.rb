require "formula"

class IgnitionMsgs < Formula
  homepage "https://bitbucket.org/ignitionrobotics/ign_msgs"
  head "https://bitbucket.org/ignitionrobotics/ign_msgs", :branch => 'clang', :using => :hg

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
