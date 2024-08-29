class Sdformat15 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-15.0.0~pre2.tar.bz2"
  version "15.0.0-pre2"
  sha256 "f75d8655e1c2adbe8043d6588734b163f13bc7f7e934c167a32635af3ef23fd1"
  license "Apache-2.0"

  head "https://github.com/gazebosim/sdformat.git", branch: "sdf15"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "3848d3a44e0f558d436b10cb2c3ec343c0bbe7124e2eb5a64a0ba37d9b6ec5f6"
    sha256 monterey: "61fc52446413668fc6eaf924fc8adc331f3909952c64f670d6dd6266218e5491"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "pybind11" => :build

  depends_on "doxygen"
  depends_on "gz-cmake4"
  depends_on "gz-math8"
  depends_on "gz-tools2"
  depends_on "gz-utils3"
  depends_on macos: :mojave # c++17
  depends_on "python@3.12"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def python_cmake_arg
    "-DPython3_EXECUTABLE=#{which("python3")}"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"
    cmake_args << python_cmake_arg

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.12/site-packages").install Dir[lib/"python/*"]
    rmdir prefix/"lib/python"
  end

  test do
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
      find_package(sdformat15 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${SDFormat_LIBRARIES})
    EOS
    system "pkg-config", "sdformat15"
    cflags = `pkg-config --cflags sdformat15`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat15",
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
    system Formula["python@3.12"].opt_bin/"python3.12", "-c", "import sdformat15"
  end
end
