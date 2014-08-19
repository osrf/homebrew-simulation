require "formula"

class ChronoEngine < Formula
  homepage "http://www.projectchrono.org/chronoengine/"
  url "https://github.com/projectchrono/chrono/archive/2.0.0.tar.gz"
  sha1 "bee6b3513e6b632cdac777d79e86da269d8a94cf"
  head "https://github.com/projectchrono/chrono.git", :branch => 'develop'

  depends_on 'cmake' => :build
  depends_on 'irrlicht' => :optional

  fails_with :clang do
    build 503
    cause 'HACD problem'
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << '-DENABLE_UNIT_IRRLICHT=True' if build.with? 'irrlicht' and build.head?

    mkdir 'build' do
      system "cmake", "../src", *cmake_args
      system "make", "install"
    end
  end

  def caveats
    s = ''

    if build.with? 'irrlicht' and !build.head?
      s += "The '--with-irrlicht' option requires '--HEAD'"
      s += ", irrlicht demos are disabled"
    end
    return s.empty? ? nil : s
  end
end
