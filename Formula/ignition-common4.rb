class IgnitionCommon4 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-common"
  url "https://osrf-distributions.s3.amazonaws.com/gz-common/releases/ignition-common-4.9.0.tar.bz2"
  sha256 "2028ae185171afd86c5a38442fc3f0a9b13297e47f0ac1578a01b6b16cad0b92"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "3e82db80bbb0d6a533f08cb90b8a6c04b4553f7c99d9c16aaadeeaa16986ff76"
    sha256 cellar: :any, arm64_sonoma:  "f654672009dc1b8be05642cbf5003c7730c4d821d8f776f932ec49fde9b33bb6"
    sha256 cellar: :any, sonoma:        "70978f8b151f0240d1ec50750a4295ecb224c02f8b1258bd56a6ffbd6cc24370"
  end

  # head "https://github.com/gazebosim/gz-common.git", branch: "ign-common4"

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gts"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-utils1"
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
      #include <ignition/common.hh>
      int main() {
        igndbg << "debug" << std::endl;
        ignwarn << "warn" << std::endl;
        ignerr << "error" << std::endl;
        // // this example code doesn't compile
        // try {
        //   ignthrow("An example exception that is caught.");
        // }
        // catch(const ignition::common::exception &_e) {
        //   std::cerr << "Caught a runtime error " << _e.what() << std::endl;
        // }
        // ignassert(0 == 0);
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-common4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-common4"
    cflags = `pkg-config --cflags ignition-common4`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common4",
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
