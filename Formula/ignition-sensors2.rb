class IgnitionSensors2 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/5258e71574442d4cea910297541ffc95972ef6af.tar.bz2"
  version "1.999.999~20190312~5258e715"
  sha256 "05e242350122a9b1e89163297c64237e710feb33a49d27bf8143e17d677d278b"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs3"
  depends_on "ignition-rendering2"
  depends_on "ignition-transport6"
  depends_on "sdformat8"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/sensors.hh>

      int main()
      {
        ignition::sensors::Noise noise(ignition::sensors::NoiseType::NONE);

        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-sensors2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-sensors2::ignition-sensors2)
    EOS
    # test building with pkg-config
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-sensors2"
    cflags   = `pkg-config --cflags ignition-sensors2`.split(" ")
    ldflags  = `pkg-config --libs ignition-sensors2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
