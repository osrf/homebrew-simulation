class IgnitionFuelTools7 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/ignition-fuel_tools-7.3.1.tar.bz2"
  sha256 "b8224c574406147ae008ed9a0ac459f1e2582f6aaef7ba44e1fd1c5ac97b6de8"
  license "Apache-2.0"
  revision 32

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "ign-fuel-tools7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "ef9dcc7c5c2c760dcf41f5923986b8fd7bc06860ccd101bd79d206dae18df49a"
    sha256 cellar: :any, arm64_sonoma:  "05d1613af4711c6793c3b5ed5223653c38d64d9f00c0f4806e83a4f367319b44"
    sha256 cellar: :any, sonoma:        "38324871082ce204dc28889d1e190d4dffb60c04aee8aa757cb7b03e09df0041"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-msgs8"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/fuel_tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-fuel_tools7 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools7::ignition-fuel_tools7)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools7"
    cflags = `pkg-config --cflags ignition-fuel_tools7`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools7",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
