class GzCommon6 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-6.0.1.tar.bz2"
  sha256 "a9b0607697e430b8561b7c1c0497f24ed9765552f1d6be0023421c35a5ee1f2f"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-common.git", branch: "gz-common6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "8769fbf3a14a37ffc56268d8622f1e5ccfc473b870bce73e34d2089c18cd9ddb"
    sha256 cellar: :any, ventura: "6905d7bd316ff5d42c9cec8caebdc42b86661fb1eea29b69f62d8ede437c44b9"
  end

  depends_on "assimp"
  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gdal"
  depends_on "gz-cmake4"
  depends_on "gz-math8"
  depends_on "gz-utils3"
  depends_on macos: :high_sierra # c++17
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
