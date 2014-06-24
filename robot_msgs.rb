require "formula"

class RobotMsgs < Formula
  homepage "https://bitbucket.org/osrf/robot_msgs"
  url 'http://www.gazebosim.org/assets/distributions/robot-msgs-0.2.0.tar.bz2'
  sha1 '38c1460a56ec9d91fe7f4fdf0fbe63baa412184a'
  head "https://bitbucket.org/osrf/robot_msgs", :branch => 'c++11', :using => :hg

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
