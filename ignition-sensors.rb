class IgnitionSensors < Formula
  desc "Common libraries for robotics applications. Sensors Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/d87cd152c6415be98c07b2daa2e86fd4978c894e.tar.gz"
  version "0.0.0~20181201~d87cd15"
  sha256 "85561f6e7f61e6744e57d8cc2fb8d3d443f31e6c7d81c7eeebfba334fa2044a8"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  depends_on "cmake" => :build

  depends_on "ignition-msgs1"
  depends_on "ignition-common0"
  depends_on "ignition-math4"
  depends_on "ignition-transport4"
  depends_on "ignition-rendering"
  depends_on "sdformat6"

  depends_on "pkg-config" => :run

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent

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
