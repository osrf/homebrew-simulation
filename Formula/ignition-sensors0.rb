class IgnitionSensors0 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/6f3b5f091187dfa6385ba1f1449c2472b7f6916b.tar.gz"
  version "0.1.0~pre1~1~6f3b5f0"
  sha256 "4ee68a62e6355fd4e7465449d67e9adfa11a1d793d2c62644453e6d0b96512d3"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "f000b97a9c526ea2022fa9a7e9c9a2bc5313e0d1e5ddd0507e5ce4b595a9c8f4" => :mojave
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
