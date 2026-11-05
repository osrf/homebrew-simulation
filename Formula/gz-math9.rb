class GzMath9 < Formula
  desc "Math API for robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/gz-math-9.3.0.tar.bz2"
  sha256 "d17aaa2d7bf010b20984a70007550d96b088abf543ae403091300661e8ffdb44"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-math.git", branch: "gz-math9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_tahoe:   "b6f45d93e52140da8539bdd81b655ad4c89bfb7beca78a76930fbb3a479d69c0"
    sha256 cellar: :any, arm64_sequoia: "c297077dba51ee6316a78710de38b5253cb97981c315d29b3026a1b0087779cb"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "python@3.15" => [:build, :test]
  depends_on "pkgconf" => :test
  depends_on "eigen"
  depends_on "gz-cmake5"
  depends_on "gz-utils4"
  depends_on "ruby"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.15"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  conflicts_with "gz-rotary-math", because: "both install gz-math"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # first build without python bindings
    mkdir "build" do
      system "cmake", "-S", "..", "-B", ".", *cmake_args, "-DSKIP_PYBIND11=ON"
      system "make", "install"
    end

    # now build only the python bindings
    pythons.each do |python|
      # remove @ from formula name
      python_name = python.name.tr("@", "")
      mkdir "build_#{python_name}" do
        system "cmake", "-S", "../src/python_pybind11", "-B", ".", *cmake_args, python_cmake_arg(python)
        system "make", "install"
        (lib/"#{python_name}/site-packages").install Dir[lib/"python/*"]
        rmdir prefix/"lib/python"
      end
    end
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
      find_package(gz-math QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-math::gz-math)
    EOS
    system "pkg-config", "gz-math"
    cflags = `pkg-config --cflags gz-math`.split
    ldflags = `pkg-config --libs gz-math`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", "-S", "..", "-B", "."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
    # check python import
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.math"
    end
    system formula_opt_libexec("python3")/"bin/python", "-c", "import gz.math"
  end
end
