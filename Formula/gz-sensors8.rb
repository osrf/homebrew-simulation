class GzSensors8 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-8.0.0~pre1.tar.bz2"
  version "8.0.0~pre1"
  sha256 "08727c2e048f4013deeed32b808323b96855c6e849ca3e86a578c26129e996c0"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-sensors.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "1e7335feeeb206d7bf48825b96a441033e2d4ec8a1f703fed9e07c84eb1be2ed"
    sha256 cellar: :any, monterey: "e21a6511600dcb92c6eb0d22bb27d4ddf38ea4690b01f78d17ce6aefc6c1856c"
    sha256 cellar: :any, big_sur:  "38c1c5f892f265e1934d5b8013f4848fbafe6958fbb35fe2db49654e9eeec554"
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
