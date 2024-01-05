class Sdformat9 < Formula
  desc "Simulation Description Format"
  homepage "http://sdformat.org"
  url "https://osrf-distributions.s3.amazonaws.com/sdformat/releases/sdformat-9.10.0.tar.bz2"
  sha256 "5660d4d1547f4e4039e3ad64830b29d2ebfc6aab2aa86ed86d8d8305ee4eb3c2"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/sdformat.git", branch: "sdf9"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "doxygen"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on macos: :mojave # c++17
  depends_on "tinyxml"
  depends_on "urdfdom"

  patch do
    # Fix ruby syntax
    # Remove with next release
    url "https://github.com/gazebosim/sdformat/commit/6890d65de952b37a6d8935c0f6d823d26ff8aa86.patch?full_index=1"
    sha256 "f0524bbc4d40de81024a9ac804fdb43683d974919dfe46cb583f920640a8da3a"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
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
      find_package(sdformat9 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${SDFormat_LIBRARIES})
    EOS
    system "pkg-config", "sdformat9"
    cflags = `pkg-config --cflags sdformat9`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lsdformat9",
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
