class IgnitionCommon1 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-1.0.1.tar.bz2"
  sha256 "fb56178cda1860cbab0c29d93b46a3e0c275cb400383c6e7c5b99e4ae5b1375a"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "8cf5a38360434a8104556a8ddca664d082fdcae8131c299e2b5f799a22df6c0c" => :high_sierra
    sha256 "2057e1398a4e8c6fcfdac2a347b24db544203fef5edcf51fa346a27ee7a9ea02" => :sierra
    sha256 "c950430520481fef1818c636b8f1eb25f2bd1033635c6b5073b8c1d0775321af" => :el_capitan
  end

  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math4"
  depends_on "ossp-uuid"
  depends_on "tinyxml2"

  depends_on "cmake" => :run
  depends_on "pkg-config" => :run

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
      find_package(ignition-common1 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-common1"
    cflags = `pkg-config --cflags ignition-common1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common1",
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
