class IgnitionCommon1 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-1.1.1.tar.bz2"
  sha256 "2e8b65c9390bc78088865d95c0933c564b07b3b55b68c14e1c6d947ca8d9525a"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any
    sha256 "7fac4d4859c6224b86a96742ea13da1ba4a2ac312df98fbcf60f8a62b1f22c6a" => :mojave
    sha256 "9dc34e66f32fd63b5792c5c4385ffe5ec81895133da5a26e600e88381b665646" => :high_sierra
    sha256 "c64df45c5240d326046cc79300e0ca435bc94734ced04fe93cf06b79b8c9fb1f" => :sierra
  end

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math4"
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
      find_package(ignition-common1 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    ENV.append "PKG_CONFIG_PATH", Formula["tinyxml2@6.2.0"].opt_lib/"pkgconfig"
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
