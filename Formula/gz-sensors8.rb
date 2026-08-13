class GzSensors8 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-8.2.2.tar.bz2"
  sha256 "9ddc16d5cab0a86f27771732f5cfcfde1efe7611f27da61176ea122273806c42"
  license "Apache-2.0"
  revision 39

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256               arm64_sequoia: "5f7f978492263f77374f72285ef4786d0c15f053a5b134a42484658e879b7cd4"
    sha256               arm64_sonoma:  "fb0ba84f2760ef51418eaee62e9c8dbc9ddc31cf4ce5f363b70c619972f964bf"
    sha256 cellar: :any, sonoma:        "6bca270cc5655d1e8f652036374c966187c09ad6e3ca6a178bb84b75ba37640f"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "abseil"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-msgs10"
  depends_on "gz-rendering8"
  depends_on "gz-transport13"
  depends_on "gz-utils2"
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
