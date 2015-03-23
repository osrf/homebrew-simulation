require 'formula'

class Simbody < Formula
  homepage 'https://simtk.org/home/simbody'
  url 'https://github.com/simbody/simbody/archive/Simbody-3.5.1.tar.gz'
  sha256 '8e1f8faae6c1fd7d5f10707fa1c0152a5cab2178a20c5967cd2ed84a3f0325f4'
  head 'https://github.com/simbody/simbody.git', :branch => 'master'

  depends_on 'cmake' => :build
  depends_on 'doxygen' => :build

  def install
    ENV.m64

    cmake_args = std_cmake_args.select { |arg| arg.match(/CMAKE_BUILD_TYPE/).nil? }
    cmake_args << "-DCMAKE_BUILD_TYPE=Release"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "doxygen"
      system "make", "install"
    end
  end
end
