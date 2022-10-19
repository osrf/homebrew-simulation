class GzCommon5 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-5.2.1~pre2.tar.bz2"
  version "5.2.1~pre2"
  sha256 "e62187c5ebf6b514b9ca66c5d79dd33c2bdafd2dbab35b94ce46c1a138ae1c18"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-common.git", branch: "gz-common5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "b5d2d1adeda2571cc2e09513aeb7c4367b88199b03efc1783db565052dbce22e"
    sha256 cellar: :any, big_sur:  "e1385d7bd1746cba7b5c43fd89e88d5af6c95081e7383662a01ab6acae6235f2"
    sha256 cellar: :any, catalina: "f47d151d6cc4b0ff16cdffb0bf0cbf8bce482cdb16255750fc67cce769d411a1"
  end

  depends_on "assimp"
  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gdal"
  depends_on "gts"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-utils2"
  depends_on macos: :high_sierra # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
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
      find_package(gz-common5 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-common5::gz-common5)
    EOS
    system "pkg-config", "gz-common5"
    cflags = `pkg-config --cflags gz-common5`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-common5",
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
