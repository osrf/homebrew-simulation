class IgnitionFuelTools7 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/ignition-fuel_tools-7.3.1.tar.bz2"
  sha256 "b8224c574406147ae008ed9a0ac459f1e2582f6aaef7ba44e1fd1c5ac97b6de8"
  license "Apache-2.0"
  revision 46

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "ign-fuel-tools7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "ddc26d4d70c0ccd5fa48e531aac26809e0b4511bf59d25f4c6e1dc00cdafebf1"
    sha256 cellar: :any, arm64_sonoma:  "8c9883725353ba4412f8b5a57e49c5bea5ce47ffcd90895cfd0f7d80eaad4d97"
    sha256 cellar: :any, sonoma:        "25e638c0b79d53e243ff958e25151933bdb5617608375fbc5a4ba76a85a998e8"
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
