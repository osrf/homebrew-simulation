class GzSensors10 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-10.0.1.tar.bz2"
  sha256 "6f16c4c125d283536f49642109f62b2cdccfc7a421d4b33a1350d46ab7e831a3"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256               arm64_sequoia: "b986cfc1883a02f0ef246c0f93b6f45b44a919d0a64312b063e6feb888129c62"
    sha256               arm64_sonoma:  "eda807fefafec85112148d957749b4a1675c05e6cb8f04f6af1b88d81d3b01c7"
    sha256 cellar: :any, sonoma:        "c848e4b0c5af0fe41ba39c4aabb1e26034f8b50335a9a1dc69c8e5ce5d44ccdd"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "abseil"
  depends_on "fmt"
  depends_on "gz-jetty-cmake"
  depends_on "gz-jetty-common"
  depends_on "gz-jetty-math"
  depends_on "gz-jetty-msgs"
  depends_on "gz-jetty-rendering"
  depends_on "gz-jetty-sdformat"
  depends_on "gz-jetty-transport"
  depends_on "gz-jetty-utils"
  depends_on "protobuf"
  depends_on "spdlog"
  depends_on "tinyxml2"

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
