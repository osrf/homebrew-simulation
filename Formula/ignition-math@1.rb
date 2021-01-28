class IgnitionMathAT1 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-math/releases/ignition-math-1.0.0.tar.bz2"
  sha256 "5c15bbafdab35d1e0b2f9e43ea13fc665e29c19530c94c89b92a86491128b30a"
  license "Apache-2.0"
  head "https://github.com/ignitionrobotics/ign-math.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "false"
  end
end
