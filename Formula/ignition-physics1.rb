class IgnitionPhysics1 < Formula
  desc "Physics library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics-1.3.1.tar.bz2"
  sha256 "5c15bb7fa466e1dee821ffc4495a37fb365014217c68b9a445534ce896c5f12f"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "97a6be3bc0872a059dcf7db6dc55e81380e7a5b59c87f9ab74f82e33b3cd2748" => :mojave
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
