require "formula"

class IgnitionMath < Formula
  head "https://bitbucket.org/ignitionrobotics/ign_math", :branch => 'default', :using => :hg

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
