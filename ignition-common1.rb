class IgnitionCommon1 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-common"
  url "http://gazebosim.org/distributions/ign-common/releases/ignition-common-1.1.0.tar.bz2"
  sha256 "e05d39a2b48c49bbe92701db25cab790d3d5a7f5eac6aa6a9fc1edeadbd7e6ea"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-common", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-common/releases"
    sha256 "f7be30a707380232e4fc3c74847259e0a3b8c6aaa2cd814e88f52a13aa4da930" => :high_sierra
    sha256 "514e08b1536386559b4f4b8815e97e62fe9724fd8b96ab53ded66ff2015c474f" => :sierra
    sha256 "5af33ed88052a3f8442fff34b9bbc6e7b67d0277b991da16e56117ae5da221ce" => :el_capitan
  end

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-math4"
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "tinyxml2"

  patch do
    # Fix for ffmpeg4
    url "https://bitbucket.org/ignitionrobotics/ign-common/commits/d937173602af5e6d5c22ced4a80bd0cf3f2f9fff/raw/"
    sha256 "564ca08bcd547df579a42d4f94aeae0423723b21eb67a9c9d4be2c3025f7dcb4"
  end

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
