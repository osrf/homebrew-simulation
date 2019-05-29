class IgnitionPhysics1 < Formula
  desc "Physics library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics-1.2.0~pre1.tar.bz2"
  version "1.2.0~pre1"
  sha256 "230049da06c5f367559b73e2d2a82b0e1a2c5215fa3fdf6f5bdc1b0e80141d68"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "b69320e9667d79b51dcb617ca8fad751925209774667ff14478a32296200a2e5" => :mojave
  end

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "google-benchmark"
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
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
