class Tinyxml2AT620 < Formula
  desc "Improved tinyxml (in memory efficiency and size)"
  homepage "http://grinninglizard.com/tinyxml2"
  url "https://github.com/leethomason/tinyxml2/archive/6.2.0.tar.gz"
  sha256 "cdf0c2179ae7a7931dba52463741cf59024198bbf9673bf08415bcb46344110f"
  license "Zlib"
  head "https://github.com/leethomason/tinyxml2.git"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, mojave:      "a16e13fc6ceac3a8ffcbe45488a4470bba3c952ce0b4276fe0d9ff5e1aa1b88a"
    sha256 cellar: :any, high_sierra: "637f0aa44b20a917a9beb4df3936fab769522bb51120d8a7c169afc178bbfe2b"
    sha256 cellar: :any, sierra:      "2506e3cc7884679407cda212db6a920cb2df68276fcf80f42657faa89873556c"
  end

  keg_only "temporary version until tinyxml2.pc is fixed"

  depends_on "cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <tinyxml2.h>
      int main() {
        tinyxml2::XMLDocument doc (false);
        return 0;
      }
    EOS
    system ENV.cc, "test.cpp", "-I#{include}", "-L#{lib}", "-ltinyxml2", "-o", "test"
    system "./test"
  end
end
