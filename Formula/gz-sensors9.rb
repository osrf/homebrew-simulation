class GzSensors9 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/gz-sensors-9.2.0.tar.bz2"
  sha256 "af2ec9a453a830338e80e94954160030e81b3ff8f60853e7c5730cdd2950be85"
  license "Apache-2.0"
  revision 22

  head "https://github.com/gazebosim/gz-sensors.git", branch: "gz-sensors9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256               arm64_sequoia: "ded62948e43d7170455ef19dca4a6d62449d80cc187b6f9a5cb8b0fe3fcd6152"
    sha256               arm64_sonoma:  "a91c7678b9f47811d1142ef3496928215e3d6be09ec3d736fe1dba54fc5d0d29"
    sha256 cellar: :any, sonoma:        "521c9b313ff770627e602060067b9c0d8ce2c3f814412b1dc916daa10695edb7"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "abseil"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-math8"
  depends_on "gz-msgs11"
  depends_on "gz-rendering9"
  depends_on "gz-transport14"
  depends_on "gz-utils3"
  depends_on "protobuf"
  depends_on "sdformat15"
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
      find_package(gz-sensors9 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sensors9::gz-sensors9)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-sensors9"
    cflags   = `pkg-config --cflags gz-sensors9`.split
    ldflags  = `pkg-config --libs gz-sensors9`.split
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
