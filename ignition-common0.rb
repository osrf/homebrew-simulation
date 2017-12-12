class IgnitionCommon0 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.5.0~pre3.tar.bz2"
  version "0.5.0~pre3"
  sha256 "b6406b840c549d8d7fa2c1409ef8ec5e90f7b973c8f3e6f39378d74447a69142"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "532870f8f81a2dd6e6768f7fc90b526e7a405f0d6fbe85891587c3e5e9a4b50f" => :high_sierra
    sha256 "9d7c5d3a299b39db42c6527b793e0f6509c46aa16a686cd9c12b29dd30d4922a" => :sierra
    sha256 "1abf3d743da411281ef1fec05e2ab52125ea140dd7e190e3684ce4430606f4b1" => :el_capitan
  end

  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math4"
  depends_on "ossp-uuid"
  depends_on "tinyxml2"

  depends_on "cmake" => :run
  depends_on "pkg-config" => :run

  patch do
    # tinyxml2 6.0.0
    url "https://bitbucket.org/ignitionrobotics/ign-common/commits/b9fff1943f8cf5bd24df13eab203e10bee92d52d/raw/"
    sha256 "befead146b67989d96794d5ac947021980978362c6f7195b31994f84a46dd0c3"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
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
    (testpath/"CMakeLists.txt").write <<-EOS.undent
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-common0 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-common0"
    cflags = `pkg-config --cflags ignition-common0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common0",
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
