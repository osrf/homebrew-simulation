class IgnitionSensors6 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors6-6.3.0.tar.bz2"
  sha256 "74a6da45be6322ad0eae67ddd0083f35489e527b0b9fee1b0914a6922fee0616"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "0448034f865b7b297a9fb2aeef1581f4a6585e7a5009c21055f0665a0382284e"
    sha256 cellar: :any, catalina: "6e529f6f91396a2bb385d4d4d604c33b8482b702962e9f963525bc29b05b5e20"
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
