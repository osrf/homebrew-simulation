class IgnitionSensors6 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors6-6.0.0~pre1.tar.bz2"
  version "6.0.0~pre1"
  sha256 "c47064d7c0c2e39d7ec8e0ae8e3c059591f2a40a920767ed7cd6ffd8751f6a7a"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "04049cfbe685cf5ee0b45c9fd0953ee575e115321ff84df27b022bda30286c1d"
    sha256 cellar: :any, catalina: "8149cb3fdc9dce98af27f1255e590fe636492e75101323278e9cab63901c19c2"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs8"
  depends_on "ignition-rendering6"
  depends_on "ignition-transport11"
  depends_on "sdformat12"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

    system "cmake", ".", *cmake_args
    system "make", "install"
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
      find_package(ignition-sensors6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors6::ignition-sensors6)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors6"
    cflags   = `pkg-config --cflags ignition-sensors6`.split
    ldflags  = `pkg-config --libs ignition-sensors6`.split
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
