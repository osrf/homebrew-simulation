class IgnitionPhysics0 < Formula
  desc "Physics library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-physics"
  url "https://bitbucket.org/ignitionrobotics/ign-physics/get/d85b70f7d31c3dc41580f5dcb5e6bc2ec28345ba.tar.gz"
  version "0.0.0~20180409~d85b70f"
  sha256 "c48b640c4dca5a861df5f41c58bd4a45e74a2a6ff17bfee205926608c9eb8a33"

  head "https://bitbucket.org/ignitionrobotics/ign-physics", :branch => "default", :using => :hg

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-math5"
  depends_on "pkg-config"

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
    system "pkg-config", "ignition-physics0"
    cflags   = `pkg-config --cflags ignition-physics0`.split(" ")
    ldflags  = `pkg-config --libs ignition-physics0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
