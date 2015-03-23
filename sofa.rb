class Sofa < Formula
  homepage "http://www.sofa-framework.org"
  head "svn://scm.gforge.inria.fr/svn/sofa/trunk/Sofa"

  depends_on "cmake" => :build
  depends_on :x11
  depends_on 'glew'
  depends_on 'libpng'
  depends_on 'qt' => 'with-qt3support'

  def install
    # For some reason, cmake must be invoked twice
    system "cmake", ".", *std_cmake_args
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
