class GzCommon7 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-7.0.1.tar.bz2"
  sha256 "eb308626fdac0a887915c034166515222e64cddcb4acd4472111e46831d6b1bb"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-common.git", branch: "gz-common7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "80afa45f2478079ef2225ec08c22d63634390dce310378bc83577149e297495c"
    sha256 cellar: :any, arm64_sonoma:  "03e654a246872a1386f767d754c394faee38a4da32ffce7b1c947c4950df3ab7"
    sha256 cellar: :any, sonoma:        "fa26c0db5f84bb1b7610c40ec9955aaee8ed6acae268fd2a27ebd27c05842737"
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
      ENV.append "LIBRARY_PATH", Formula["gettext"].opt_lib
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
