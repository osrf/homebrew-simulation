class IgnitionSensors6 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors6-6.7.1.tar.bz2"
  sha256 "5b01cb99ff8b1effc0bdaa0309f4378894ace2640644ee3f2b96d44ff3aa10f0"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-sensors.git", branch: "ign-sensors6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "7cd6696ff080b36c46fd15ee4da82f23d1d569f1a0e4a7a5a0db10d9b51e2353"
    sha256 cellar: :any, monterey: "0d24debd89942757529fa6b90edc83c811303be55b30450bd9a700790d001915"
    sha256 cellar: :any, big_sur:  "b00d71b1f1e3bd0b9e5e2e7100f487e10c9d1769f78ef1198c63933481da1175"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs8"
  depends_on "ignition-rendering6"
  depends_on "ignition-transport11"
  depends_on "protobuf"
  depends_on "sdformat12"

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
