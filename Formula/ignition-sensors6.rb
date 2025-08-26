class IgnitionSensors6 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sensors/releases/ignition-sensors-6.8.1.tar.bz2"
  sha256 "abc96be3bd018cae94c83981d173af0f67ce2980ef7a1374b34bd5b63f9a7235"
  license "Apache-2.0"
  revision 20

  head "https://github.com/gazebosim/gz-sensors.git", branch: "ign-sensors6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256               arm64_sonoma: "432e0f9ec0aa4db58af1d834e9503234874ae49a1fa4764b9ef32076d7f01420"
    sha256 cellar: :any, sonoma:       "78770b399f08d22691e8dacfdf355e11a1f42d7737b3e98da6f87969d341a6b6"
    sha256 cellar: :any, ventura:      "74ebfd5fa64a1aadcbd9d04d51447ad78212e7d1e6dabdc48af620561c273990"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs8"
  depends_on "ignition-rendering6"
  depends_on "ignition-transport11"
  depends_on "protobuf"
  depends_on "sdformat12"
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
      #include <ignition/sensors/Noise.hh>

      int main()
      {
        ignition::sensors::Noise noise(ignition::sensors::NoiseType::NONE);

        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-sensors6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors6::ignition-sensors6)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors6"
    cflags   = `pkg-config --cflags ignition-sensors6`.split
    ldflags  = `pkg-config --libs ignition-sensors6`.split
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
