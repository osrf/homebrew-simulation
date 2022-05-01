class IgnitionSensors5 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors5-5.1.1.tar.bz2"
  sha256 "92943c50e92b02cfef71671939a90f0a35ea17a9237c2ac95b3b2d683c2aa180"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-sensors.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "bf36e8a6220c5cee9beae83c8ae52f431c7c07ca2d725a44d68fb7fc81f81ce6"
    sha256 catalina: "834eef78970c07ad11453ac967f240413ed091006bbc90ff51405e0458dc7063"
  end

  deprecate! date: "2022-03-31", because: "is past end-of-life date"

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
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

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
