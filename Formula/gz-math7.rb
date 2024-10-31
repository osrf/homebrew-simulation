class GzMath7 < Formula
  desc "Math API for robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/gz-math-7.5.1.tar.bz2"
  sha256 "cb1fc3436fd57ff9663613576fc208018ed6c11776972e555400d1b8bb7d2426"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-math.git", branch: "gz-math7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "fc68e0969e29460070b13ce4cbb49e53c9802821267ef6aad64e55bffca068ec"
    sha256 cellar: :any, ventura: "1d95728e7a681a67aa0ac9899e9bcc1e7ca0f03835ba4c79f3e17eaa0b26d0a7"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "pkg-config" => :test
  depends_on "eigen"
  depends_on "gz-cmake3"
  depends_on "gz-utils2"
  depends_on "ruby"

  patch do
    # Support building python bindings against external gz-math library (1)
    # Remove this patch with the next release
    url "https://github.com/gazebosim/gz-math/commit/97ad436a0d561c77422de83cebb600379cc9c94a.patch?full_index=1"
    sha256 "6d2ed400c7067ac123c80d762f796d2b75e3b4ab479ee71b019e253ca41724e8"
  end

  patch do
    # Support building python bindings against external gz-math library (2)
    # Remove this patch with the next release
    url "https://github.com/gazebosim/gz-math/commit/a48b8937eadd4010a69b9f9613ca07aaa1f87d63.patch?full_index=1"
    sha256 "fbd10f7b886511586ab84c7c03771a43da2fbb5c9445037a6534bbdbd2d05062"
  end

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = "python@3.13".to_formula)
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
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
