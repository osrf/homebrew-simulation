class Tinyxml2AT620 < Formula
  desc "Improved tinyxml (in memory efficiency and size)"
  homepage "http://grinninglizard.com/tinyxml2"
  url "https://github.com/leethomason/tinyxml2/archive/6.2.0.tar.gz"
  sha256 "cdf0c2179ae7a7931dba52463741cf59024198bbf9673bf08415bcb46344110f"
  head "https://github.com/leethomason/tinyxml2.git"

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
