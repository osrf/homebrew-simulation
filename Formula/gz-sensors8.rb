class GzSensors8 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-8.1.0.tar.bz2"
  sha256 "5271ff1df50c319c5ed454dbc260805aab52435298139773b46aaf5929be5f9e"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "92ca5137832068d97366d524992dfe115ab5695f58cc60ad17af23fcc123a43a"
    sha256 cellar: :any, monterey: "5dc3e512ac99095df66397480e3a091147a8f9689a884413b5106141d28760a2"
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
