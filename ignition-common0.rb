class IgnitionCommon0 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  # url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.4.0.tar.bz2"
  url "https://bitbucket.org/ignitionrobotics/ign-common/get/4c05367a7c0c64c1f647bb424eb5f829e696768f.tar.gz"
  version "0.4.0~20171011~4c05367"
  sha256 "1d36c3b86cc87236f53a815cb84d3b3a78d9bac58a629fb9752cc9eb94d840c4"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "37024f64d990765753406631b27a02c11bf0e5c036b0ee30190e9f1a5595d7e2" => :high_sierra
    sha256 "25483747704aaa04f1d86423e67c195f6f50b57297049d751e7d966a388b6f82" => :sierra
    sha256 "167ab634b6f3afeb0ae72c53c5c6752f3f5d81248b6a1762909b20dc5f00265d" => :el_capitan
    sha256 "ca64d8eca4af6b1a5ff3588c6a58e8c091a9c3d45bf38edd5e336064b79dfc13" => :yosemite
  end

  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math4"
  depends_on "ossp-uuid"
  depends_on "tinyxml2"

  depends_on "cmake" => :run
  depends_on "pkg-config" => :run

  # find ignition-math4 in cmake config file
  patch :DATA

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
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end

__END__
diff -r 65af64810c62 cmake/ignition-common-config.cmake.in
--- a/cmake/ignition-common-config.cmake.in	Wed Oct 11 16:19:59 2017 -0700
+++ b/cmake/ignition-common-config.cmake.in	Wed Oct 11 17:34:25 2017 -0700
@@ -43,4 +43,4 @@
 set(@PKG_NAME@_LIBRARY_DIRS "@PACKAGE_LIB_INSTALL_DIR@")
 set(@PKG_NAME@_LDFLAGS      "-L@PACKAGE_LIB_INSTALL_DIR@")
 
-find_package(ignition-math3 REQUIRED)
+find_package(ignition-math4 REQUIRED)

