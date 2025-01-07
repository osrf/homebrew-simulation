class IgnitionCommon1 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-common"
  url "https://osrf-distributions.s3.amazonaws.com/ign-common/releases/ignition-common-1.1.1.tar.bz2"
  sha256 "2e8b65c9390bc78088865d95c0933c564b07b3b55b68c14e1c6d947ca8d9525a"
  license "Apache-2.0"
  revision 7

  head "https://github.com/gazebosim/gz-common.git", branch: "ign-common1"

  deprecate! date: "2023-01-25", because: "is past end-of-life date"
  disable! date: "2024-08-31", because: "is past end-of-life date"

  depends_on "cmake"
  depends_on "ffmpeg@4"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math4"
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

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
      find_package(ignition-common1 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["ffmpeg@4"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-common1"
    cflags = `pkg-config --cflags ignition-common1`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common1",
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
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
