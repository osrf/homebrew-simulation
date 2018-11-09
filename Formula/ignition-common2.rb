class IgnitionCommon2 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common2-2.0.0~pre1.tar.bz2"
  version "2.0.0~pre1"
  sha256 "9b5fe63d091b2eb2584642b76befba1144268963b2cdeaefdf795062817de217"
  revision 2

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any
    sha256 "339f3895ae57a9519f9683ec36114e827134734f5a32c2874023b5cdd2382728" => :mojave
    sha256 "5bc9842a45bc0dd3f94d461e9489001685199e541fc164d01c262579e931507b" => :high_sierra
    sha256 "08299d6d7ffdd71c9678c27b77de28fe780c79521be0909ec29af2dc7cd9acbb" => :sierra
  end

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-cmake1"
  depends_on "ignition-math5"
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "tinyxml2@6.2.0"

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
      find_package(ignition-common2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-common2"
    cflags = `pkg-config --cflags ignition-common2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common2",
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
