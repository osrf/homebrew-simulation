class IgnitionSensors5 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors5-5.0.0~pre1.tar.bz2"
  version "5.0.0~pre1"
  sha256 "16bbb65f3583ae1e516b1898765748b13278e0cf3902b00f57c8c70db354b68e"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-sensors.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "ad73cc1e6247723beb5f84b31c97bdb235c2652ed98c49bf045a5fdf16b1bfe2"
    sha256 mojave:   "bb1ed0b6cce5b93a9104a77688ea1cc6f38bbb6fbc118369148701051ebd944f"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs7"
  depends_on "ignition-rendering5"
  depends_on "ignition-transport10"
  depends_on "sdformat11"

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
      find_package(ignition-sensors5 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors5::ignition-sensors5)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors5"
    cflags   = `pkg-config --cflags ignition-sensors5`.split
    ldflags  = `pkg-config --libs ignition-sensors5`.split
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
