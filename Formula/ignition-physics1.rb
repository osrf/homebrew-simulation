class IgnitionPhysics1 < Formula
  desc "Physics library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-physics"
  url "https://bitbucket.org/ignitionrobotics/ign-physics/get/57d272bc9f44.tar.gz"
  version "1.0.0~pre5~1~57d272b"
  sha256 "d2630703ce6a64508386bd73748820ae7e052a24beabdf0ac40b1e2d1a23bb03"

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any
    sha256 "7915a9b58f2a41ab5f41eb42ca3fba264a0149040829446dfad7cc4917098f3c" => :mojave
  end

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat8"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "ignition/physics.hh"
      int main()
      {
        ignition::physics::CompositeData data;
        return data.Has<std::string>();
      }
    EOS
    system "pkg-config", "ignition-physics1"
    cflags   = `pkg-config --cflags ignition-physics1`.split(" ")
    ldflags  = `pkg-config --libs ignition-physics1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
