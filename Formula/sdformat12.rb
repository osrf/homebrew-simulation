class Sdformat12 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://github.com/osrf/sdformat.git", branch: "main"
  version "11.999.999~1"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "8ec4d52c3a1c947e6baed0426ba812c5f565a67a2669b385d11f2091eb02cb04"
    sha256 mojave:   "f7f12a2cc038a1ed046381b4789675f149ce1982970fdf0ba798bd45cb4017eb"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "doxygen"
  depends_on "ignition-math6"
  depends_on "ignition-utils1"
  depends_on macos: :mojave # c++17
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
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
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(sdformat12 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${SDFormat_LIBRARIES})
    EOS
    system "pkg-config", "sdformat12"
    cflags = `pkg-config --cflags sdformat12`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat12",
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
  end
end
