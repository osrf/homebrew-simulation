class GzSensors7 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-7.0.0.tar.bz2"
  sha256 "1ce2bfcdc3893db9240d1d9f6def00fe920405cae82a903851f7f210fc1373ae"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "c68b368e29b379702fcfbce8d9c66218d36350210236d91f5c667cec8e56ab37"
    sha256 cellar: :any, big_sur:  "c3a886834684ae5a3b86de9c16b17b7f01e93b9c5a6503858be1dc4034be0926"
    sha256 cellar: :any, catalina: "921397a3c1ad14f3ab799e1ce6156d9193624d3248842a420ab3818e3a4a6ae1"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-msgs9"
  depends_on "gz-rendering7"
  depends_on "gz-transport12"
  depends_on "sdformat13"

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
      find_package(gz-sensors7 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sensors7::gz-sensors7)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-sensors7"
    cflags   = `pkg-config --cflags gz-sensors7`.split
    ldflags  = `pkg-config --libs gz-sensors7`.split
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
