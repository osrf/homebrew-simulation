class GzCommon7 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-7.2.0.tar.bz2"
  sha256 "0dda4b11ddf7de697c0c0b94f8a3793f689285a2699b8860bc9a4116c7deb564"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-common.git", branch: "gz-common7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "1bae33a9624a3e4c94a9fb82ad1f5936cb32dbef3549c83de6797cd32ef56ef6"
    sha256 cellar: :any, arm64_sonoma:  "82beb111135bb6c0df8412653bc792c6ab480efa5e7164e0c5373b4b1dcae183"
    sha256 cellar: :any, sonoma:        "c3b5c224fdd687a1f9a4793716a57d4382a524156dc094b66a9f3a1e39567b58"
  end

  depends_on "assimp"
  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "fmt"
  depends_on "freeimage"
  depends_on "gdal"
  depends_on "gz-cmake5"
  depends_on "gz-math9"
  depends_on "gz-utils4"
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "spdlog"
  depends_on "tinyxml2"

  conflicts_with "gz-rotary-common", because: "both install gz-common"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <gz/common.hh>
      int main() {
        gzdbg << "debug" << std::endl;
        gzwarn << "warn" << std::endl;
        gzerr << "error" << std::endl;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-common QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-common::gz-common)
    EOS
    system "pkg-config", "gz-common"
    # cflags = `pkg-config --cflags gz-common`.split
    # ldflags = `pkg-config --libs gz-common`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.append "LIBRARY_PATH", formula_opt_lib("gettext")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    # ! requires system with single argument, which uses standard shell
    # put in variable to avoid audit complaint
    # enclose / in [] so the following line won't match itself
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
