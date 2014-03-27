require 'formula'

class Simbody < Formula
  homepage 'https://simtk.org/home/simbody'
  url 'https://github.com/simbody/simbody/archive/Simbody-3.4.zip'
  sha1 'd9ef925167474601b49140c5557b84ffa701bfd2'
  head 'https://github.com/simbody/simbody.git', :branch => 'master'

  depends_on 'cmake' => :build

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "doxygen"
      system "make", "install"
    end
  end
end
