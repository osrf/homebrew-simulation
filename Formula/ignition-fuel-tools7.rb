class IgnitionFuelTools7 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/ignition-fuel_tools-7.3.1.tar.bz2"
  sha256 "b8224c574406147ae008ed9a0ac459f1e2582f6aaef7ba44e1fd1c5ac97b6de8"
  license "Apache-2.0"
  revision 44

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "ign-fuel-tools7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "60d97a05d0321a55e4a73c27f60aa3d1c78bfe455d851fad050463c16e475143"
    sha256 cellar: :any, arm64_sonoma:  "7562f98e581363636a2732b021d29cd4398cc7d24715294f7fcea3f5264e8637"
    sha256 cellar: :any, sonoma:        "9e2ca96e05bc763224ba4779723c33e11ed8fba72a93ede0386193036795f4de"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
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
