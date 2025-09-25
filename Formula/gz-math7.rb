class GzMath7 < Formula
  desc "Math API for robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/gz-math-7.5.2.tar.bz2"
  sha256 "2451435f601f1adc8fdb3580e3b55bba951822dd85dcddcc8bae4fe132587803"
  license "Apache-2.0"
  revision 2

  # head "https://github.com/gazebosim/gz-math.git", branch: "gz-math7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "09f4c01a95528cce105072bcca431deca4e94f4d8f003756d98f7872306e3e99"
    sha256 cellar: :any, arm64_sonoma:  "11ddff8d00f115477f88e6f44c1bbf2d0228ab37a389d8f11366e407f0ae11d2"
    sha256 cellar: :any, sonoma:        "99e604672f50796e7fd63a490a7c46afcc18e3c3f605da20d275749912e3c8de"
    sha256 cellar: :any, ventura:       "1475598d5d7e72eeee07a39b092b56561e2a03ebd453a5910a885550f3438f84"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "pkgconf" => :test
  depends_on "eigen"
  depends_on "gz-cmake3"
  depends_on "gz-utils2"
  depends_on "ruby"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.13"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # first build without python bindings
    mkdir "build" do
      system "cmake", "..", *cmake_args, "-DSKIP_PYBIND11=ON"
      system "make", "install"
    end

    # now build only the python bindings
    pythons.each do |python|
      # remove @ from formula name
      python_name = python.name.tr("@", "")
      mkdir "build_#{python_name}" do
        system "cmake", "../src/python_pybind11", *cmake_args, python_cmake_arg(python)
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
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-math7 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-math7::gz-math7)
    EOS
    system "pkg-config", "gz-math7"
    cflags = `pkg-config --cflags gz-math7`.split
    ldflags = `pkg-config --libs gz-math7`.split
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
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.math7"
    end
  end
end
