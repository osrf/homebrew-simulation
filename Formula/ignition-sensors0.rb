class IgnitionSensors0 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "http://gazebosim.org/distributions/ign-sensors/releases/ignition-sensors-0.1.0~pre1.tar.bz2"
  version "0.1.0~pre1"
  sha256 "308279da4edd74bb3f08996fe71416445d8ff799b5b6764a0f259d65a67c1fbe"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  # bottle do
  #   root_url "http://gazebosim.org/distributions/ign-sensors/releases"
  #   sha256 "8b8c253114e3c6af1d6978e79b02c3c10895a5fe276a21570e370eaa4252491d" => :high_sierra
  #   sha256 "520b171c51d0415f99ae7c8ecdd955249d166bad89edcad83879b85735c9a80f" => :sierra
  #   sha256 "42acd100d3187950a56ec3fde87349feb78368d7c3552a9a1344f0c031511f72" => :el_capitan
  # end

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
