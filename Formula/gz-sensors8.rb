class GzSensors8 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-8.0.1.tar.bz2"
  sha256 "fc67417da4b6675050e52789d64c4298f1088daca3eebd036dc3be732f428bce"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "714a0811b944c3b76ff989d764bee042e26575aaa963e9585cd4f9bf7467b318"
    sha256 cellar: :any, monterey: "91f9419f9372c99d45d7afadee6caae75b7e14eddeef4254452f69176fe5a312"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-msgs10"
  depends_on "gz-rendering8"
  depends_on "gz-transport13"
  depends_on "protobuf"
  depends_on "sdformat14"
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
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(gz-sensors8 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sensors8::gz-sensors8)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-sensors8"
    cflags   = `pkg-config --cflags gz-sensors8`.split
    ldflags  = `pkg-config --libs gz-sensors8`.split
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
