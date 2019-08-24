class IgnitionGazebo1 < Formula
  desc "Gazebo robot simulator"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gazebo"
  url "https://osrf-distributions.s3.amazonaws.com/ign-gazebo/releases/ignition-gazebo-1.1.0.tar.bz2"
  sha256 "fd4060fbe0d4dc1ef3db9b87104a427fddae510c101b1690f0fed43f2aeea76b"
  revision 1

  head "https://bitbucket.org/ignitionrobotics/ign-gazebo", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "01a89decdbf464fa64da7a6c07e3635b9fe8d19e7ac9869b14413c30c48e17c5" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "gflags"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools3"
  depends_on "ignition-gui1"
  depends_on "ignition-math6"
  depends_on "ignition-msgs3"
  depends_on "ignition-physics1"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering1"
  depends_on "ignition-sensors1"
  depends_on "ignition-transport6"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat8"

  conflicts_with "ignition-gazebo2", :because => "Both install bin/ign-gazebo symlinks"

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
      find_package(ignition-gazebo1 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo1::core)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-gazebo1"
    cflags   = `pkg-config --cflags ignition-gazebo1`.split(" ")
    ldflags  = `pkg-config --libs ignition-gazebo1`.split(" ")
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
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
