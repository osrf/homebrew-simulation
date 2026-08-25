class GzCommon5 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/gz-common-5.9.0.tar.bz2"
  sha256 "3a853c5c305dd747592252479534e7bd8d50631635c075496cd7c4e32439e730"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "df9107ff480d3d4ae35a1b1ebd8b1cc11b60242ed3875e39176ab44cfaf26acb"
    sha256 cellar: :any, arm64_sonoma:  "543ee76c573814ba9c4d4cf3f2d80de5cfd614716d1c42e9a75cdcd8867cf4b9"
    sha256 cellar: :any, sonoma:        "1289977e7b9933519c3defb6230a834fbef4130adb456bf69a26cda4487ff1dc"
  end

  # head "https://github.com/gazebosim/gz-common.git", branch: "gz-common5"

  depends_on "assimp"
  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gdal"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gts"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-utils2"
  depends_on "ossp-uuid"
  depends_on "pkgconf"
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
