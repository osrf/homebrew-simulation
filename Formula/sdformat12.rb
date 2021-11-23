class Sdformat12 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-12.2.0.tar.bz2"
  sha256 "e66fe831f7f57a10b922f9e69bd627a12913edcb56091cc60247a447fc87e735"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "708403c835106fa4d12a39a7227e20c854f1a8c00ab8dfe984a3f1eae945c8ae"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "doxygen"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
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
