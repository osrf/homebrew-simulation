class IgnitionSensors3 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://github.com/gazebosim/gz-sensors"
  url "https://osrf-distributions.s3.amazonaws.com/ign-sensors/releases/ignition-sensors3-3.4.0.tar.bz2"
  sha256 "0a9ad4a074ec4c52b6a3a2b3c0f5450cfb9f3d6f8252d4a3b3a00156c9427d6c"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-sensors.git", branch: "ign-sensors3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "c7a64ee809dcb4a43af6b9f7b16384e2ddf64ccc7dfdf1b5b4005ee42c24f755"
    sha256 catalina: "7fe94be738d4dbf0681a83a1dd8064f33807c25fd163febe2c341ff0c1f80643"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-rendering3"
  depends_on "ignition-transport8"
  depends_on "sdformat9"

  patch do
    # Add missing DEPENDS_ON_COMPONENTS parameters to fix ignition-gazebo3 build
    # https://github.com/gazebosim/gz-sensors/pull/262
    # TODO: remove with next release
    url "https://github.com/gazebosim/gz-sensors/commit/da66843e251c6ee2e82c96dd691dc2cd0cd9d32d.patch?full_index=1"
    sha256 "801dc8c8a906b6964d13fcfe753b843820d20508ecb1f8bbc7dc49ae18d1309c"
  end

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
      find_package(ignition-sensors3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors3::ignition-sensors3)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-sensors3"
    cflags   = `pkg-config --cflags ignition-sensors3`.split
    ldflags  = `pkg-config --libs ignition-sensors3`.split
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
