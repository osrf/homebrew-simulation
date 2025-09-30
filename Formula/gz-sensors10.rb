class GzSensors10 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-10.0.0.tar.bz2"
  sha256 "7712bfe969b726f54c26d9aedccb6c04c6616e5e20dd4a379f48e77a89b73dc7"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256               arm64_sequoia: "a68581e1efa16ef063e40eded04be43ee527193c3533d657c9d6100dfa81d689"
    sha256               arm64_sonoma:  "527845932ba376044e2b549d4bed8e2ca294618b78f9bb8564d6c66ae32f0df5"
    sha256 cellar: :any, sonoma:        "4aea5da67aa3013779ee5bf5c220dc8d2c90d8308a332c5bad8981cc85c757d0"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "abseil"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-rendering10"
  depends_on "gz-transport15"
  depends_on "gz-utils4"
  depends_on "protobuf"
  depends_on "sdformat16"
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
