class IgnitionPhysics1 < Formula
  desc "Physics library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics-1.1.0~pre1.tar.bz2"
  version "1.1.0~pre1"
  sha256 "203d69390fc27220f18d33f157ab4691be34cd6536f49f99e4c03e4dfb2fd30c"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "7b825aaf156943805d68331657082cfccce7b0a1a7bffd7a214b3022ad61d384" => :mojave
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
