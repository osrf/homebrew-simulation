require 'formula'

class Simbody < Formula
  homepage 'https://simtk.org/home/simbody'
  url 'https://github.com/simbody/simbody/archive/Simbody-3.4.1.zip'
  sha1 '785442e5c8b24c8925c5aec47aba14c6a2413b0b'
  head 'https://github.com/simbody/simbody.git', :branch => 'master'

  depends_on 'cmake' => :build
  depends_on 'doxygen' => :build

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "doxygen"
      system "make", "install"
    end
  end
end
