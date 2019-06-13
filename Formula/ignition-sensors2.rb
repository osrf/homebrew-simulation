class IgnitionSensors2 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors2-2.1.0~pre2.tar.bz2"
  version "2.1.0~pre2"
  sha256 "ac72943a6448e25e4d9e879f4c74d87ad3c0ecdffe71f1482132484468e874b1"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "de12d0308dd0b598d544fe5b83dfda4ab00c01bf1b79374b92373ae07a1ef694" => :mojave
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs4"
  depends_on "ignition-rendering2"
  depends_on "ignition-transport7"
  depends_on "sdformat8"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/sensors.hh>

      int main()
      {
        ignition::sensors::Noise noise(ignition::sensors::NoiseType::NONE);

        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-sensors2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors2::ignition-sensors2)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors2"
    cflags   = `pkg-config --cflags ignition-sensors2`.split(" ")
    ldflags  = `pkg-config --libs ignition-sensors2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
