class IgnitionSensors4 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/84f8018bc3185ada6f4e85a8d0728f2cdd3b3699.tar.gz"
  version "3.999.999~0~20200408~84f8018"
  sha256 "73522f74aa29fbb423c6908dd1670a5298ce2609a54cd95cb5901b47198af914"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "e199155d71d9b114d16c28f0a928bf8295c1761a1a92e0d885a3535de302bc0a" => :mojave
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-rendering4"
  depends_on "ignition-transport8"
  depends_on "sdformat9"

  def install
    system "cmake", ".", *std_cmake_args
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
    cflags   = `pkg-config --cflags ignition-sensors4`.split(" ")
    ldflags  = `pkg-config --libs ignition-sensors4`.split(" ")
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
