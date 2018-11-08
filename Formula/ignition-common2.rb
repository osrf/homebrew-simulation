class IgnitionCommon2 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common2-2.0.0~pre1.tar.bz2"
  version "2.0.0~pre1"
  sha256 "9b5fe63d091b2eb2584642b76befba1144268963b2cdeaefdf795062817de217"
  revision 2

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    cellar :any
    sha256 "3e0925b493ce47d880c9b65c0baf518172df63114b6156304b04d2e07dad374b" => :mojave
    sha256 "7e65176beddd592784d0779b98f3c63a19cafda6bf9b1c8b80a75a71538b4081" => :high_sierra
    sha256 "7008c61aa2aa5c90688169e4c4b698d06f111b3123a44c2f3b04937152b8611b" => :sierra
    sha256 "cae42cb31ffd664a1108bc79154ee39697c012cb3dcdf276c8cd139dbd474433" => :el_capitan
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
