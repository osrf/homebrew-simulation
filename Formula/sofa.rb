class Sofa < Formula
  desc "Physics framework sofa"
  homepage "http://www.sofa-framework.org"
  head "https://github.com/sofa-framework/sofa.git"

  depends_on "cmake" => :build
  depends_on "glew"
  depends_on "libpng"
  depends_on "qt" => "with-qt3support"

  depends_on :x11

  def install
    # For some reason, cmake must be invoked twice
    system "cmake", ".", *std_cmake_args
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
