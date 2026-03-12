class GzRotarySensors < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sensors.git", branch: "main"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "abseil"
  depends_on "fmt"
  depends_on "gz-rotary-cmake"
  depends_on "gz-rotary-common"
  depends_on "gz-rotary-math"
  depends_on "gz-rotary-msgs"
  depends_on "gz-rotary-rendering"
  depends_on "gz-rotary-sdformat"
  depends_on "gz-rotary-transport"
  depends_on "gz-rotary-utils"
  depends_on "protobuf"
  depends_on "spdlog"
  depends_on "tinyxml2"

  conflicts_with "gz-jetty-sensors", because: "both install gz-sensors"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  def caveats
    <<~EOS
      This is an unstable, development version of Gazebo built from source.
    EOS
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <gz/sensors/Noise.hh>

      int main()
      {
        gz::sensors::Noise noise(gz::sensors::NoiseType::NONE);

        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-sensors QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sensors::gz-sensors)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-sensors"
    cflags   = `pkg-config --cflags gz-sensors`.split
    ldflags  = `pkg-config --libs gz-sensors`.split
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
