class Simbody < Formula
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.5.3.tar.gz"
  sha256 "8005fbdb16c6475f98e13b8f1423b0e9951c193681c2b0d19ae5b711d7e24ec1"
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
