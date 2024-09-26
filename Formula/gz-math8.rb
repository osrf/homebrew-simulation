class GzMath8 < Formula
  desc "Math API for robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/gz-math-8.0.0.tar.bz2"
  sha256 "dfc15a78aa52f5e200da991e92ebcbd0bd6f9529326dbe3a1a365ad6d7da9669"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-math.git", branch: "gz-math8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:   "0f362a8f8c932901077cd38aabdb5cd63083a3803e2b7ef285588751c980987d"
    sha256 cellar: :any, ventura:  "ff757c2861fb8b4e64e21a2e4d3564fd667614568f5e2fd0f4c5e62f2a26da91"
    sha256 cellar: :any, monterey: "9efcad2afece87a47b5df6b89ddb479fa91d7739aa36b1323b2c5a591ae5896b"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "pkg-config" => :test
  depends_on "eigen"
  depends_on "gz-cmake4"
  depends_on "gz-utils3"
  depends_on "python@3.12"
  depends_on "ruby"

  def python_cmake_arg
    "-DPython3_EXECUTABLE=#{which("python3")}"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"
    cmake_args << python_cmake_arg

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.12/site-packages").install Dir[lib/"python/*"]
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
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-math8 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-math8::gz-math8)
    EOS
    system "pkg-config", "gz-math8"
    cflags = `pkg-config --cflags gz-math8`.split
    ldflags = `pkg-config --libs gz-math8`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
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
    system Formula["python@3.12"].opt_bin/"python3.12", "-c", "import gz.math8"
  end
end
