class GzSensors10 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-10.0.1.tar.bz2"
  sha256 "6f16c4c125d283536f49642109f62b2cdccfc7a421d4b33a1350d46ab7e831a3"
  license "Apache-2.0"
  revision 12

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256               arm64_sequoia: "09a45d7f40197206380c90ec55e8a02fa74c3c877ef1555f1c56e332f7201e16"
    sha256               arm64_sonoma:  "5f09603cc7e96a47e5284ce27eec498f604f529bb788948c6522f5039401c4ba"
    sha256 cellar: :any, sonoma:        "5f7e1ba9b264f2b2c1b42eb0aafafdd9729bf583422f37b6283e6f8a88690f9c"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "abseil"
  depends_on "fmt"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-rendering10"
  depends_on "gz-transport15"
  depends_on "gz-utils4"
  depends_on "protobuf"
  depends_on "sdformat16"
  depends_on "spdlog"
  depends_on "tinyxml2"

  conflicts_with "gz-rotary-sensors", because: "both install gz-sensors"

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
