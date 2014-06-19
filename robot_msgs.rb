require "formula"

class RobotMsgs < Formula
  homepage "https://bitbucket.org/osrf/robot_msgs"
  url "http://gazebosim.org/assets/distributions/robot-msgs-0.1.0.tar.bz2"
  sha1 "09152d9890569faa435d48e50fa168458ae96e30"
  head "https://bitbucket.org/osrf/robot_msgs", :branch => 'default', :using => :hg

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "osrf/simulation/protobuf"
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
