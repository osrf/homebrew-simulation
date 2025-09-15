class IgnitionCommon4 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-common"
  url "https://osrf-distributions.s3.amazonaws.com/ign-common/releases/ignition-common4-4.7.0.tar.bz2"
  sha256 "ec9bb68be9f6323f3a3a12b23259c567f9a2478951719573e1b7c906bd7e68cb"
  license "Apache-2.0"
  revision 13

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sonoma: "44c75078157b60ef4f8d6c6f065aba064b3eca50d263a8a3f3fc63237d2b8a5c"
    sha256 cellar: :any, sonoma:       "800f084d88f125aeec75bfdb451ec33fe1b5abca478a36dbaeaf3b2d8ee6e168"
    sha256 cellar: :any, ventura:      "2ce2850638a703c84c8348de6cffcb4d8033c86449a6b84ed95c95191f789e99"
  end

  # head "https://github.com/gazebosim/gz-common.git", branch: "ign-common4"

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-utils1"
  depends_on "ossp-uuid"
  depends_on "pkgconf"
  depends_on "tinyxml2"

  patch do
    # Fix for compatibility with ffmpeg 8, part 1
    url "https://github.com/gazebosim/gz-common/commit/e1a21e064ed799c830389a8c139a297215c9715f.patch?full_index=1"
    sha256 "3b4fbb850016a911a00ede06da6b1d2d48b91ab06adf91912884467a668dc4f0"
  end

  patch do
    # Fix for compatibility with ffmpeg 8, part 2
    url "https://github.com/gazebosim/gz-common/commit/ac3fd976334ce3712f773179dd6c820ba286b652.patch?full_index=1"
    sha256 "85422d4b7579a9b8612c101f6af28818031c27a6a4cc36b756d146166ae4e800"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
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
      find_package(ignition-common4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-COMMON_LIBRARIES})
    EOS
    system "pkg-config", "ignition-common4"
    cflags = `pkg-config --cflags ignition-common4`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common4",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.append "LIBRARY_PATH", Formula["gettext"].opt_lib
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    # ! requires system with single argument, which uses standard shell
    # put in variable to avoid audit complaint
    # enclose / in [] so the following line won't match itself
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
