class IgnitionCommon3 < Formula
  desc "Common libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-common"
  url "https://osrf-distributions.s3.amazonaws.com/ign-common/releases/ignition-common3-3.16.0.tar.bz2"
  sha256 "2f01e46ecef680b9bbab0be71f61aac46e9a1625084e3d3bdb70c526754730b4"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-common.git", branch: "ign-common3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "68a95bf32afccc4b773d268814976ca8e4b5b4de591edde70e3200cfa8aa546a"
    sha256 cellar: :any, monterey: "3f6ca9d7fb45d95d6b9765329c98c15f5fa352477514591bf9e8f81a53da465f"
    sha256 cellar: :any, big_sur:  "7f280c787e5990dc8affb4d760bcef6bef14ab050394db1ca2cb0b79151c99c6"
  end

  depends_on "cmake"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "gts"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on macos: :high_sierra # c++17
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    if Hardware::CPU.arm?
      # REVISIT: this works around a crash on Apple M1 processors
      # https://github.com/osrf/homebrew-simulation/pull/1698#discussion_r774674536
      cmake_args << "-DIGN_PROFILER_REMOTERY=Off"
    end

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # Remove an accidentally installed CMakeLists.txt file
    # remove this at next release
    rm Dir[include/"ignition/common3/CMakeLists.txt"]
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
    cflags = `pkg-config --cflags ignition-common3`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-common3",
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
