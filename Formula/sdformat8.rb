class Sdformat8 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-8.7.0.tar.bz2"
  sha256 "e39331f35c2161ca34b9e78cac5e42664b8e9e08136bce13c8c9b1ea0bdd5bf0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "b7c9b0960d11bcd7b5c770dadcb8cc548d4961dfe6de6e6fe5ccd2f8236dc909" => :mojave
  end

  depends_on "cmake" => :build

  depends_on "doxygen"
  depends_on "ignition-math6"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "tinyxml"
  depends_on "urdfdom" => :optional

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DUSE_EXTERNAL_URDF:BOOL=True" if build.with? "urdfdom"
    cmake_args << ".."

    mkdir "build" do
      system "cmake", *cmake_args
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
      find_package(sdformat8 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${SDFormat_LIBRARIES})
    EOS
    system "pkg-config", "sdformat8"
    cflags = `pkg-config --cflags sdformat8`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat8",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
