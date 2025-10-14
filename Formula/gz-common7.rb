class GzCommon7 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-7.0.0.tar.bz2"
  sha256 "592f17171730925a384918008851541cd7eb278c76226485926cd609120094f5"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-common.git", branch: "gz-common7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "adacf7e87629b2be2684579784e0d9527d4e7e30bd63c2dbbd0ffcbaf35b4dfe"
    sha256 cellar: :any, arm64_sonoma:  "9e02541118455f17eb0220c664083df59ac86a90a5a30312d98baf70bede47c3"
    sha256 cellar: :any, sonoma:        "9b3b30852200696a2a5fc79348ca9a1f3ecbb40546b0e4f61a0d5de0e0a874b8"
  end

  depends_on "assimp"
  depends_on "cmake"
  depends_on "ffmpeg"
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
