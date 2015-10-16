class Simbody < Formula
  desc "Simbody multibody physics API"
  homepage "https://simtk.org/home/simbody"
  url "https://github.com/simbody/simbody/archive/Simbody-3.5.3.tar.gz"
  sha256 "8005fbdb16c6475f98e13b8f1423b0e9951c193681c2b0d19ae5b711d7e24ec1"
  head "https://github.com/simbody/simbody.git", :branch => "master"

  bottle do
    root_url "http://gazebosim.org/distributions/simbody/releases"
    sha256 "69186db06f20a5dd3da38429cd96e3b5b8e900cb02bc1db6803f2d06435df09f" => :yosemite
  end

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
