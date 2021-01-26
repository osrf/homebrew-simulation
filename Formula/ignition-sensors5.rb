class IgnitionSensors5 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-sensors"
  url "https://github.com/ignitionrobotics/ign-sensors/archive/c42ffce0d5d37141a27f357ab72c6666179e6308.tar.gz"
  version "4.999.999~0~20210112~c42ffc"
  sha256 "46f87a2977c7ea04e12c64ff1205eabb48acd6acdf822c7f65664ae249f78352"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-sensors", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "92ebe9ca507b7156571a30467d7569109323830d9ba95462c4447b211cbbabc6" => :mojave
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
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
