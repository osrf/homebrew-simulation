class IgnitionGazebo3 < Formula
  desc "Ignition Gazebo robot simulator"
  homepage "https://github.com/ignitionrobotics/ign-gazebo"
  url "https://osrf-distributions.s3.amazonaws.com/ign-gazebo/releases/ignition-gazebo3-3.4.0.tar.bz2"
  sha256 "b16074dd65c3a1b0b72cfa0aa60b6fc67394d3ee3b53d6f89bfcbd6180260c01"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-gazebo", branch: "ign-gazebo3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "01c89edca2279a17e838bebb1d65a280f3bb11a55e2e6661879684c6bf64633a" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools4"
  depends_on "ignition-gui3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-physics2"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering3"
  depends_on "ignition-sensors3"
  depends_on "ignition-transport8"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat9"

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

    mkdir "build" do
      system "cmake", "..", *cmake_args
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
      find_package(ignition-gazebo3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo3::core)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "ignition-gazebo3"
    # cflags   = `pkg-config --cflags ignition-gazebo3`.split(" ")
    # ldflags  = `pkg-config --libs ignition-gazebo3`.split(" ")
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
