require "formula"

class IgnitionMath < Formula
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ignition/releases/ignition-math-0.1.0.tar.bz2"
  sha1 "6585d7124bcecb055058a9695c0f295af1b9046b"
  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => 'default', :using => :hg

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :optional]

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
