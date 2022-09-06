class GzMath7 < Formula
  desc "Math API for robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/gz-math-7.0.0~pre1.tar.bz2"
  version "7.0.0~pre1"
  sha256 "0a8c1184a87a71f8a6a91fa1cec08e7f5f8d5df992abcbceb247226e0e6a20b3"
  license "Apache-2.0"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "2dee018ae1e3157ce027cd9f68a133b28851df9f95a34f582cd260e302f0ccdd"
    sha256 cellar: :any, catalina: "9fa84203302250efbb48ef3b63b3bded9307cfb46f67af4f287565ef35806d5d"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "eigen"
  depends_on "gz-cmake3"
  depends_on "gz-utils2"
  depends_on "python@3.10"
  depends_on "ruby"

  patch do
    # Don't link to python libraries
    url "https://github.com/gazebosim/gz-math/commit/bedd27bf88b33693fe2592ee758957479af857de.patch?full_index=1"
    sha256 "7c4129fe1f99ed60f2d18deef38fcc958a303616b1323dfc22e58e557d481d61"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"
    system "cmake", ".", *cmake_args
    system "make", "install"

    (lib/"python3.10/site-packages").install Dir[lib/"python/*"]
    rmdir prefix/"lib/python"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "gz/math/SignalStats.hh"
      int main() {
        gz::math::SignalMean mean;
        mean.InsertData(1.0);
        mean.InsertData(-1.0);
        return static_cast<int>(mean.Value());
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-math7 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-math7::gz-math7)
    EOS
    # test building with manual compiler flags
    system ENV.cc, "test.cpp",
                   "--std=c++14",
                   "-I#{include}/gz/math7",
                   "-L#{lib}",
                   "-lgz-math7",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
    # check python import
    system Formula["python@3.10"].opt_bin/"python3.10", "-c", "import gz.math"
  end
end
