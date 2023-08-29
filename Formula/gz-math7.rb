class GzMath7 < Formula
  desc "Math API for robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/gz-math-7.3.0.tar.bz2"
  sha256 "cc9d677b9f231cd5efde357375c862756f68c21acfb59bfc1e4f9133cf1fccc0"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-math.git", branch: "gz-math7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "f92631a1e8f6f8a0e8f711a7bdea9ec24dfaf61638d4fc4747dc60ad7c6e7909"
    sha256 cellar: :any, monterey: "459c2f26b77a408fdaf8032084eb476ae283ff32ac4cd425adecd759622a7d8f"
    sha256 cellar: :any, big_sur:  "5894d11632234d417757c9f344b372f584e0e4d9f8ce9514fe3553d7439c6c0a"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "eigen"
  depends_on "gz-cmake3"
  depends_on "gz-utils2"
  depends_on "python@3.11"
  depends_on "ruby"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.11/site-packages").install Dir[lib/"python/*"]
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
    system Formula["python@3.11"].opt_bin/"python3.11", "-c", "import gz.math7"
  end
end
