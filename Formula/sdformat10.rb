class Sdformat10 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://github.com/osrf/sdformat/archive/1e213886f892e6accd1c7b0f104a8af2583ed68b.tar.gz"
  version "9.999.999~0~20200604~1e21388"
  sha256 "8b33c4675c7447a780d676bf40c50925524d210982f857d6ffb17a2279f745ca"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "doxygen"
  depends_on "ignition-math6"
  depends_on :macos => :mojave # c++17
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    ENV.m64

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
      find_package(sdformat10 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${SDFormat_LIBRARIES})
    EOS
    system "pkg-config", "sdformat10"
    cflags = `pkg-config --cflags sdformat10`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat10",
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
