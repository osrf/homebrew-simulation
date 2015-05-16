class Simbody < Formula
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.5.2.tar.gz"
  sha256 "f0b9ef0398b9d99a29e7ef8e08ac3470ebfa991788f450a19ceffe3673eb8306"
  head "https://github.com/simbody/simbody.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "doxygen"
      system "make", "install"
    end
  end
end
