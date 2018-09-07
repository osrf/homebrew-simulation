class IgnitionCommon3 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common3-3.0.0~pre1.tar.bz2"
  version "3.0.0~pre1"
  sha256 "3b5be2abfe8e449e3a88ff31c243099aa79d05d1c3ae910071af2a2d59c788d1"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "ed849a7bd95816f97707d5ba80fb7dab2bfbaa04dd49cabe812e1bf44fae2233" => :high_sierra
    sha256 "c4f3227c005cc3e5d20380cedf10185bc449ef6825b268f82a1f951200e4834a" => :sierra
    sha256 "c089d7503118af55b4191b24989fa00ba2b1c65034e4b35d59d1e39aa84fae5a" => :el_capitan
  end

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
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
