class IgnitionSensors0 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/a1506694b185f77146b6c9daf5b2a8b093d7e70f.tar.bz2"
  version "0.1.0~pre2~a1506694b"
  sha256 "63facb721a69cde014c2edf82f49199f5fafddf189675cf36bbbe5f6bc916556"
  version_scheme 1

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "de50b7582709ae52c8b312e1e46e8c4be68859fe20cd289cc664b708d0bb91e1" => :mojave
  end

  depends_on "cmake" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs3"
  depends_on "ignition-rendering1"
  depends_on "ignition-transport6"
  depends_on "pkg-config"
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
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-sensors0"
    cflags   = `pkg-config --cflags ignition-sensors0`.split(" ")
    ldflags  = `pkg-config --libs ignition-sensors0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
