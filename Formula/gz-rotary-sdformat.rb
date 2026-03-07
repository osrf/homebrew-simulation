class GzRotarySdformat < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  license "Apache-2.0"

  head "https://github.com/gazebosim/sdformat.git", branch: "main"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "pybind11" => :build
  depends_on "python@3.12" => [:build, :test]
  depends_on "python@3.13" => [:build, :test]
  depends_on "python@3.14" => [:build, :test]

  depends_on "doxygen"
  depends_on "gz-rotary-cmake"
  depends_on "gz-rotary-math"
  depends_on "gz-rotary-tools"
  depends_on "gz-rotary-utils"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.13"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  conflicts_with "gz-jetty-sdformat", because: "both install gz-sdformat"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/sdformat", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

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
        system "cmake", "../python", *cmake_args, python_cmake_arg(python)
        system "make", "install"
        (lib/"#{python_name}/site-packages").install Dir[lib/"python/*"]
        rmdir prefix/"lib/python"
      end
    end
  end

  def caveats
    <<~EOS
      This is an unstable, development version of Gazebo built from source.
    EOS
  end

  test do
    # Test standalone executable
    system libexec/"gz/sdformat/gz-sdformat-sdf"
    # Test compiling against API
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include "sdf/sdf.hh"
      const std::string sdfString(
        "<sdf version='1.5'>"
        "  <model name='example'>"
        "    <link name='link'>"
        "      <sensor type='gps' name='mysensor' />"
        "    </link>"
        "  </model>"
        "</sdf>");
      int main() {
        sdf::SDF modelSDF;
        modelSDF.SetFromString(sdfString);
        std::cout << modelSDF.ToString() << std::endl;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(sdformat QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${SDFormat_LIBRARIES})
    EOS
    system "pkg-config", "sdformat"
    cflags = `pkg-config --cflags sdformat`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat",
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
      system python.opt_libexec/"bin/python", "-c",
        "import sdformat; sdformat.Box().size()"
    end
    system Formula["python3"].opt_libexec/"bin/python", "-c",
      "import sdformat; sdformat.Box().size()"
  end
end
