class IgnitionSensors4 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors4-4.2.0.tar.bz2"
  sha256 "89b24c4a6282183329a4512b753ec46d06685cea4f74b3c6b1e3238a08a2ff76"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-sensors.git", branch: "ign-sensors4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "4f9dbddcab51bda5837f2ff880c054dcfb63b5a41fc0294531676041baa13000"
    sha256 mojave:   "ffebcbb87d9b87c45df455ae6162f6adbf68479f0a22f7704d02990047349c11"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs6"
  depends_on "ignition-rendering4"
  depends_on "ignition-transport9"
  depends_on "sdformat10"

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
      find_package(ignition-sensors4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors4::ignition-sensors4)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors4"
    cflags   = `pkg-config --cflags ignition-sensors4`.split
    ldflags  = `pkg-config --libs ignition-sensors4`.split
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
