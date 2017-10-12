class IgnitionCommon0 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  # url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-0.4.0.tar.bz2"
  url "https://bitbucket.org/ignitionrobotics/ign-common/get/41840173c59de679f80cb9a94c94645d618311cd.tar.gz"
  version "0.4.0~20171011~4184017"
  sha256 "4887e157c8b91acf5e1912d1443178c18384140792a92047914463c1b6a841f0"

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "7efad0b723d7ef3a5e76cae3abeef60df127108003cac31eac51f3195b3206d8" => :high_sierra
    sha256 "c488c4f2b4a3c4a85d6bb594b32478a530579f52087f183d602ad5d0fe0816d1" => :sierra
    sha256 "167ab634b6f3afeb0ae72c53c5c6752f3f5d81248b6a1762909b20dc5f00265d" => :el_capitan
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
