class IgnitionSensors5 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors5-5.0.0.tar.bz2"
  sha256 "33c6c062418ac325be6143c494ad8f6187deaae95af8f77f9978582a67bd6e9d"
  license "Apache-2.0"
  revision 2

  head "https://github.com/ignitionrobotics/ign-sensors.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "fddefb7a86e570f96d04cc846f82951415606cb40dda4123a689cab458106a63"
    sha256 mojave:   "ed54512f04894ed76ef458395ec39d358093e7a726083b2aed998e5185acecf1"
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
