class GzCommon6 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-6.3.0.tar.bz2"
  sha256 "e70e8916f3a82cf6dd7b42e18a68acbc12cd8e9ac433759db4427f8356dc366d"
  license "Apache-2.0"
  revision 2

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "e3d84b5a8ca5356ae48891b48de6c14181e325bf1b7ea9fcd9ef6e52a21f09d1"
    sha256 cellar: :any, arm64_sonoma:  "45da9242c37e38de32c2cf20d731a7a26892823113bd88aaeff0a5930ccae1db"
    sha256 cellar: :any, sonoma:        "82e858425830d1500f2ec08ad9c1087774c3e17f679290cdf1ffd278ea907168"
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
