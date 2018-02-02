class IgnitionSensors0 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/d87cd152c6415be98c07b2daa2e86fd4978c894e.tar.gz"
  version "0.0.0~20171201~d87cd15"
  sha256 "e5d7e9cfc28349a331728d6e30cbdf7e9aaca16a0b8e6b0960158ad955d95682"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  depends_on "cmake" => :build

  depends_on "ignition-common1"
  depends_on "ignition-math4"
  depends_on "ignition-msgs1"
  depends_on "ignition-rendering0"
  depends_on "ignition-transport4"
  depends_on "sdformat6"

  depends_on "pkg-config" => :run

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>

      #include <ignition/rendering.hh>
      #include <ignition/sensors.hh>

      int main()
      {
        // Setup ign-rendering with a scene
        auto *engine = ignition::rendering::engine("ogre");
        if (!engine)
        {
          std::cerr << "Failed to load ogre\n";
          return 1;
        }
        ignition::rendering::ScenePtr scene = engine->CreateScene("scene");

        // Add stuff to take a picture of
        BuildScene(scene);

        // Create a sensor manager
        ignition::sensors::Manager mgr;
        mgr.SetRenderingScene(scene);

        return 0;
      }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-sensors"
    cflags   = `pkg-config --cflags ignition-sensors`.split(" ")
    ldflags  = `pkg-config --libs ignition-sensors`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
