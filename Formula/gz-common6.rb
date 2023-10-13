class GzCommon6 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://github.com/gazebosim/gz-common.git", branch: "main"
  version "5.999.999-0-20231009"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-common.git", branch: "gz-common6"

  depends_on "assimp"
  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gdal"
  depends_on "gts"
  depends_on "gz-cmake4"
  depends_on "gz-math8"
  depends_on "gz-utils3"
  depends_on macos: :high_sierra # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use build folder
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
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-common6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-common6::gz-common6)
    EOS
    system "pkg-config", "gz-common6"
    cflags = `pkg-config --cflags gz-common6`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-common6",
                   "-lc++",
                   "-o", "test"
    system "./test"
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
