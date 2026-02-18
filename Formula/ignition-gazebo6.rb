class IgnitionGazebo6 < Formula
  desc "Ignition Gazebo robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sim/releases/ignition-gazebo-6.17.1.tar.bz2"
  sha256 "30001eff50b175565e5d10df5a6ad3dab8638f3c2ea53e365ac264bc33f6b04d"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sim.git", branch: "ign-gazebo6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "ea2613f84f14b5d7c57550393b38e2f1988d1e8a7c3f0a6eecbc64ef57e3a279"
    sha256 arm64_sonoma:  "f9d054bc44ccd9638013ffaba8f8a6ab080e7c4dd2c60e447053d714362bb9d0"
    sha256 sonoma:        "f02496348ad3b67f7208b9b2abb83e1512c3dda5f5d9888ccf4661b4c3687008"
  end

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "gz-plugin2" => :test
  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-fuel-tools7"
  depends_on "ignition-gui6"
  depends_on "ignition-math6"
  depends_on "ignition-msgs8"
  depends_on "ignition-physics5"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering6"
  depends_on "ignition-sensors6"
  depends_on "ignition-tools"
  depends_on "ignition-transport11"
  depends_on "ignition-utils1"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "python@3.11"
  depends_on "qt@5"
  depends_on "ruby"
  depends_on "sdformat12"
  depends_on "tinyxml2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"ign-gazebo-6/plugins", target: lib),
      rpath(source: lib/"ign-gazebo-6/plugins/gui", target: lib),
      rpath(source: lib/"ign-gazebo-6/plugins/gui/GzSim", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    require "system_command"
    extend SystemCommand::Mixin

    # test some plugins in subfolders
    plugin_info = lambda { |p|
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    }
    %w[altimeter log physics sensors].each do |system|
      plugin_info.call lib/"ign-gazebo-6/plugins/libignition-gazebo-#{system}-system.dylib"
    end
    ["libAlignTool", "libEntityContextMenuPlugin", "libGzSceneManager", "IgnGazebo/libEntityContextMenu"].each do |p|
      plugin_info.call lib/"ign-gazebo-6/plugins/gui/#{p}.dylib"
    end
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system Formula["ignition-tools"].opt_bin/"ign",
           "gazebo", "-s", "--iterations", "5", "-r", "-v", "4"
    # build against API
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
      find_package(ignition-gazebo6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo6::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "ignition-gazebo6"
    # cflags   = `pkg-config --cflags ignition-gazebo6`.split
    # ldflags  = `pkg-config --libs ignition-gazebo6`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
    # test building with cmake
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_prefix
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
