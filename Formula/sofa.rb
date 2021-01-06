class Sofa < Formula
  desc "Physics framework sofa"
  homepage "https://www.sofa-framework.org"
  url "https://github.com/sofa-framework/sofa/archive/v19.12.00.tar.gz"
  sha256 "830f6cfe237feea545f2afb85d8797330db6712ce4581886d83e9c47372285ba"
  license "LGPL-2.1"

  head "https://github.com/sofa-framework/sofa.git"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "eigen"
  depends_on "glew"
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "libx11"
  depends_on "qt@5"

  def install
    # For some reason, cmake must be invoked twice
    system "cmake", ".", *std_cmake_args
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
