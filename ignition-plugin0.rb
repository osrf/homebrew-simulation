class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "https://bitbucket.org/ignitionrobotics/ign-plugin/get/1cf03327fcc11a557fbe53defa5626c69f1a7f26.tar.gz"
  version "0.0.999~20180719~1cf0332"
  sha256 "f6c32b9f45ebc231640c1255ab1b5a073383e8ab87c293fce932c9aef764a518"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    sha256 "7e65176beddd592784d0779b98f3c63a19cafda6bf9b1c8b80a75a71538b4081" => :high_sierra
    sha256 "7008c61aa2aa5c90688169e4c4b698d06f111b3123a44c2f3b04937152b8611b" => :sierra
    sha256 "cae42cb31ffd664a1108bc79154ee39697c012cb3dcdf276c8cd139dbd474433" => :el_capitan
  end

  depends_on "cmake"
  depends_on "ignition-cmake1"
  depends_on "pkg-config"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <ignition/plugin.hh>
      int main() {
        igndbg << "debug" << std::endl;
        ignwarn << "warn" << std::endl;
        ignerr << "error" << std::endl;
        // // this example code doesn't compile
        // try {
        //   ignthrow("An example exception that is caught.");
        // }
        // catch(const ignition::plugin::exception &_e) {
        //   std::cerr << "Caught a runtime error " << _e.what() << std::endl;
        // }
        // ignassert(0 == 0);
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-plugin0 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-plugin0"
    cflags = `pkg-config --cflags ignition-plugin0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-plugin0",
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
