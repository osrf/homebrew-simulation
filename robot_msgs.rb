require "formula"

class RobotMsgs < Formula
  homepage "https://bitbucket.org/osrf/robot_msgs"
  url "http://gazebosim.org/assets/distributions/robot-msgs-0.1.0.tar.bz2"
  sha1 "09152d9890569faa435d48e50fa168458ae96e30"

  depends_on "cmake" => :build
  depends_on "pkgconfig" => :build
  depends_on "protobuf"
  depends_on "protobuf-c" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
