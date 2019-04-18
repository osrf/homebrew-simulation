class IgnitionGazebo2 < Formula
  desc "Gazebo robot simulator"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gazebo"
  url "https://bitbucket.org/ignitionrobotics/ign-gazebo/get/717270eda240f9c087c26c65cb68043d00ff71e4.tar.bz2"
  version "1.999.999~20190418~717270e"
  sha256 "48a1c5ffd7c0ed0cdbbecb1f896b8344f8efae1b3eb2097f36504bd5f18ef86f"

  head "https://bitbucket.org/ignitionrobotics/ign-gazebo", :branch => "default", :using => :hg

  depends_on "cmake" => :build
  depends_on "gflags"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools3"
  depends_on "ignition-gui2"
  depends_on "ignition-math6"
  depends_on "ignition-msgs4"
  depends_on "ignition-physics1"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering2"
  depends_on "ignition-sensors2"
  depends_on "ignition-transport7"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat8"

  conflicts_with "ignition-gazebo1", :because => "Both install bin/ign-gazebo symlinks"

  def install
    ENV.m64

    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
    #include <cstdint>
    #include <ignition/gazebo/Entity.hh>
    #include <ignition/gazebo/EntityComponentManager.hh>
    #include <ignition/gazebo/components/World.hh>
    #include <ignition/gazebo/components/Name.hh>

    using namespace ignition;
    using namespace gazebo;

    //////////////////////////////////////////////////
    int main(int argc, char **argv)
    {
      // Warm start. Initial allocation of resources can throw off calculations.
      {
        // Create the entity component manager
        EntityComponentManager mgr;

        // Create the matching entities
        for (int i = 0; i < 100; ++i)
        {
          Entity entity = mgr.CreateEntity();
          mgr.CreateComponent(entity, components::World());
          mgr.CreateComponent(entity, components::Name("world_name"));
        }

        mgr.Each<components::World, components::Name>(
            [&](const Entity &, const components::World *,
              const components::Name *)->bool {return true;});
      }

      return 0;
    }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-gazebo2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo2::core)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-gazebo2"
    cflags   = `pkg-config --cflags ignition-gazebo2`.split(" ")
    ldflags  = `pkg-config --libs ignition-gazebo2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt"].opt_prefix
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
