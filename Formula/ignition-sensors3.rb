class IgnitionSensors3 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors3-3.6.0.tar.bz2"
  sha256 "b64b187333907a9e866307ccc76649672e0df9b6bdfb4a390929ebbcaa83ce64"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-sensors.git", branch: "ign-sensors3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "b5f60bb72905851e85b54a3c437807be3bcac96ee1d1602cefb9d5950280d058"
    sha256 monterey: "19bca3f165b601bc176c7295cdf2d62eb16d7b4389b01321023e6344a222a68c"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-rendering3"
  depends_on "ignition-transport8"
  depends_on "protobuf"
  depends_on "sdformat9"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/sensors/Noise.hh>

      int main()
      {
        ignition::sensors::Noise noise(ignition::sensors::NoiseType::NONE);

        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-sensors3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors3::ignition-sensors3)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors3"
    cflags   = `pkg-config --cflags ignition-sensors3`.split
    ldflags  = `pkg-config --libs ignition-sensors3`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
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
