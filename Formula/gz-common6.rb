class GzCommon6 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-6.3.0.tar.bz2"
  sha256 "e70e8916f3a82cf6dd7b42e18a68acbc12cd8e9ac433759db4427f8356dc366d"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "d39f927f9a13ba1d5d1fd6e8e592e0000d86b877c05537f6d0716f4c92c9643c"
    sha256 cellar: :any, arm64_sonoma:  "0ba61cd5e6336c15ccb72a9dfe3a242377ca1e9483f7c0cc391ea79cdc3c7655"
    sha256 cellar: :any, sonoma:        "3f16f1ca1ed33a95da982e2f645bc42d323e9df86581af7ff51ddd81a29322c7"
  end

  # head "https://github.com/gazebosim/gz-common.git", branch: "gz-common6"

  depends_on "assimp"
  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "fmt"
  depends_on "freeimage"
  depends_on "gdal"
  depends_on "gz-cmake4"
  depends_on "gz-math8"
  depends_on "gz-utils3"
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "spdlog"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
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
      find_package(gz-common6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-common6::gz-common6)
    EOS
    system "pkg-config", "gz-common6"
    # cflags = `pkg-config --cflags gz-common6`.split
    # ldflags = `pkg-config --libs gz-common6`.split
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
