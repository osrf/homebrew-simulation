class IgnitionCommon3 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common3-3.0.0.tar.bz2"
  sha256 "8037bbc679b807207d342b87c353badd27b7aa1b26167b0c59e89f9b4a3471c0"

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any
    sha256 "489d886f451fb2ab3a429492bcfd0986f506625de2b3c5dc535f0de2d0d0546d" => :mojave
    sha256 "d2b41b5dd61825a5607a25d0dfacc7282b1a05656569066ab8b6f2c828a171e7" => :high_sierra
  end

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on :macos => :high_sierra # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "tinyxml2"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
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
      find_package(ignition-common3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-common3"
    cflags = `pkg-config --cflags ignition-common3`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common3",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      ENV.append "LIBRARY_PATH", Formula["gettext"].opt_lib
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
