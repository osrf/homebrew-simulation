class GzSensors10 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-10.0.2.tar.bz2"
  sha256 "482bcf1e1d6db5bfc95b6ca48e7e5fb1b8f7ae719b6725d033d12a741840532a"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256               arm64_sequoia: "566cedb87eb278df1704d7edbe1d271844526bee85c0f7127b5fef1d53ecc714"
    sha256               arm64_sonoma:  "96234784ea5337e624b506054126bae4327325dc939d0adc0124bb320219b042"
    sha256 cellar: :any, sonoma:        "ef2b165ced951886ca67224138e2c3c050ea6cb3c379ec9a0dcbbbc35177af52"
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
