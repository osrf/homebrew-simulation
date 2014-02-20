require "formula"

class ChronoEngine < Formula
  homepage "http://www.projectchrono.org/chronoengine/"
  head "https://github.com/projectchrono/chrono.git", :branch => 'develop'

  depends_on 'cmake' => :build
  depends_on 'irrlicht' => :optional

  def install
    cmake_args = std_cmake_args
    cmake_args << '-DENABLE_UNIT_IRRLICHT=True' if build.with? 'irrlicht'
    mkdir 'build' do
      system "cmake", "../src", *cmake_args
      system "make", "install"
    end
  end
end
