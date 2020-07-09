class IgnitionGazebo4 < Formula
  desc "Ignition Gazebo robot simulator"
  homepage "https://github.com/ignitionrobotics/ign-gazebo"
  url "https://github.com/ignitionrobotics/ign-gazebo/archive/b1dd4006ea612f675484f6052a5c84157df2f8ab.tar.gz"
  version "3.999.999~0~20200224~78c43e7"
  sha256 "948ddeb9197c4fb8c2ff4cf59f0a86c81c45ae35fc187233ba167d37945af4d4"
  revision 2

  head "https://github.com/ignitionrobotics/ign-gazebo", :branch => "master"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "5da6b0b62880d3cea569e41a8be3b7f72e9911e5d0b86ef7ba814bf3e60dd7e4" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools5"
  depends_on "ignition-gui4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs6"
  depends_on "ignition-physics3"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering4"
  depends_on "ignition-sensors4"
  depends_on "ignition-transport9"
  depends_on :macos => :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat10"

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
      find_package(ignition-gazebo4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo4::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "ignition-gazebo4"
    # cflags   = `pkg-config --cflags ignition-gazebo4`.split(" ")
    # ldflags  = `pkg-config --libs ignition-gazebo4`.split(" ")
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
    # test building with cmake
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt"].opt_prefix
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
