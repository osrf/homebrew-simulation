class GzSensors7 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-7.3.1.tar.bz2"
  sha256 "476b86319093d488aabf951b3f4653290222991cf3a548c7d82f44c58d2794d6"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "17dbb2cd8e56a4ccc6308255d23242b769a040ed494dec843b42e6ff12846cff"
    sha256 cellar: :any, ventura: "c421f3cd369babcddb1c64949ce7a34e7ce2892db42965b36dc61271b93773b1"
  end

  deprecate! date: "2024-09-30", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "abseil"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-msgs9"
  depends_on "gz-rendering7"
  depends_on "gz-transport12"
  depends_on "gz-utils2"
  depends_on "protobuf"
  depends_on "sdformat13"
  depends_on "tinyxml2"

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
