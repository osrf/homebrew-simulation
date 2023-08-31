class Sdformat14 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-14.0.0~pre2.tar.bz2"
  version "14.0.0~pre2"
  sha256 "a838a21ec4754d3b1c67212cb17505cac7abeef2cead75c8baceda4bf2fbc905"
  license "Apache-2.0"

  head "https://github.com/gazebosim/sdformat.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "824bcaf0b16874ecd96ba9d34d0947e660438be9a953ab1cab57873e4cca4aad"
    sha256 monterey: "5ed9cbac34f3c0504b3450eead44ad1ed9fe7fc395906b6b3c5ce96f94f475d4"
    sha256 big_sur:  "5e4675c7f95e52c6c91fa6e1211f0ee6a503f0c6ed7b1fdc515b383943c539f5"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "pybind11" => :build

  depends_on "doxygen"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "python@3.11"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.11/site-packages").install Dir[lib/"python/*"]
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
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(sdformat14 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${SDFormat_LIBRARIES})
    EOS
    system "pkg-config", "sdformat14"
    cflags = `pkg-config --cflags sdformat14`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat14",
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
    system Formula["python@3.11"].opt_bin/"python3.11", "-c", "import sdformat14"
  end
end
