class GzMath8 < Formula
  desc "Math API for robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/gz-math-8.2.1.tar.bz2"
  sha256 "180fa70e41f671e3183e8115c7e5489306d16d7a2f41b10fe797c79acbae033b"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "e49733f1719f785c204f4b90319f9b00762522a3c74385bc176ae62683952c73"
    sha256 cellar: :any, arm64_sonoma:  "37bcb3668d45a6d8d8353d9054ace8897f629aa04efad44a213888360979e8a8"
    sha256 cellar: :any, sonoma:        "3340abfc34fd6d39fd2f8d89997e322ab77779f29cb3b82bcc6803a747b6db6d"
  end

  # head "https://github.com/gazebosim/gz-math.git", branch: "gz-math8"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]
  depends_on "pkgconf" => :test
  depends_on "eigen"
  depends_on "gz-cmake4"
  depends_on "gz-utils3"
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
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.math8"
    end
    system Formula["python3"].opt_libexec/"bin/python", "-c", "import gz.math8"
  end
end
