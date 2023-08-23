class GzSensors7 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-7.2.0.tar.bz2"
  sha256 "bf158cb7bde71866a3bf70e649888fe8f6f8eb0b7b77d87e991385c3b8a565af"
  license "Apache-2.0"
  revision 6

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "a0f3137dae031cff02b6623997997dd8237d098fc36c099fbf591e30e8d5e1f8"
    sha256 cellar: :any, monterey: "e10ed06924feb5a2f8321984e4ab269c8f2f0a04035b05cb5472f48cb85d7e8e"
    sha256 cellar: :any, big_sur:  "3d084ca29d28f133afca1d3ffc6f4ae1b9a90787c4ccebf2b01176d70fd31db7"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-msgs9"
  depends_on "gz-rendering7"
  depends_on "gz-transport12"
  depends_on "protobuf"
  depends_on "sdformat13"

  patch do
    # Fix for compatibility with protobuf 23.2
    url "https://github.com/gazebosim/gz-sensors/commit/0c00e0462d4babcc8df6f3e464eafb57dcc8a9df.patch?full_index=1"
    sha256 "9b763d5791c70affbf110e5cdca7d5da46aaee1250fbb9bdbd2bf05689cd1d62"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use build folder
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
