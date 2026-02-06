class GzSim10 < Formula
  desc "Gazebo Sim robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sim/releases/gz-sim-10.1.1.tar.bz2"
  sha256 "8e0dc6d216bf12f90b922b01a82211af966a8444c2b16893ed1c21f915b96f54"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-sim.git", branch: "gz-sim10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "c8da17b5b920f730068289837203de0d0299e6e077845c6ad33e5f8a50aafbba"
    sha256 arm64_sonoma:  "bf48110b62c59dcb56b3a825e0d994b3abbf0d91d4b396f9c872e87d8720e1f8"
    sha256 sonoma:        "a38fa7148733882f5781ee58e4062b5095101e3d599ca51b10176df481e274c8"
  end

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "fmt"
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "gz-jetty-cmake"
  depends_on "gz-jetty-common"
  depends_on "gz-jetty-fuel-tools"
  depends_on "gz-jetty-gui"
  depends_on "gz-jetty-math"
  depends_on "gz-jetty-msgs"
  depends_on "gz-jetty-physics"
  depends_on "gz-jetty-plugin"
  depends_on "gz-jetty-rendering"
  depends_on "gz-jetty-sdformat"
  depends_on "gz-jetty-sensors"
  depends_on "gz-jetty-tools"
  depends_on "gz-jetty-transport"
  depends_on "gz-jetty-utils"
  depends_on "libwebsockets"
  depends_on "openssl@3"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "python@3.14"
  depends_on "qt@6"
  depends_on "qtbase"
  depends_on "qtdeclarative"
  depends_on "ruby"
  depends_on "spdlog"
  depends_on "tinyxml2"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.14"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-sim-10/plugins", target: lib),
      rpath(source: lib/"gz-sim-10/plugins/gui", target: lib),
      rpath(source: lib/"gz-sim-10/plugins/gui/GzSim", target: lib),
      rpath(source: libexec/"gz/sim10", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"
    cmake_args << python_cmake_arg

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    python = pythons.first
    # remove @ from formula name
    python_name = python.name.tr("@", "")
    (lib/"#{python_name}/site-packages").install Dir[lib/"python/*"]
    rmdir prefix/"lib/python"
  end

  test do
    require "system_command"
    extend SystemCommand::Mixin

    # test some plugins in subfolders
    plugin_info = lambda { |p|
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin4"].opt_libexec/"gz/plugin4/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    }
    %w[altimeter log physics sensors].each do |system|
      plugin_info.call lib/"gz-sim-10/plugins/libgz-sim-#{system}-system.dylib"
    end
    ["libAlignTool", "libEntityContextMenuPlugin", "libGzSceneManager", "GzSim/libEntityContextMenu"].each do |p|
      plugin_info.call lib/"gz-sim-10/plugins/gui/#{p}.dylib"
    end
    # test gz-sim-main CLI tool
    system libexec/"gz/sim10/gz-sim-main",
           "-s", "--iterations", "5", "-r", "-v", "4"
    # test gz sim CLI tool
    ENV["GZ_CONFIG_PATH"] = "#{opt_share}/gz"
    system Formula["gz-jetty-tools"].opt_bin/"gz",
           "sim", "-s", "--iterations", "5", "-r", "-v", "4"
    # build against API
    (testpath/"test.cpp").write <<-EOS
    #include <cstdint>
    #include <gz/sim/Entity.hh>
    #include <gz/sim/EntityComponentManager.hh>
    #include <gz/sim/components/World.hh>
    #include <gz/sim/components/Name.hh>

    using namespace gz;
    using namespace sim;

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
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-sim QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sim::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "gz-sim"
    # cflags   = `pkg-config --cflags gz-sim`.split
    # ldflags  = `pkg-config --libs gz-sim`.split
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
    # check python import for first python in dependency list
    [pythons.first].each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.sim"
    end
    system Formula["python3"].opt_libexec/"bin/python", "-c", "import gz.sim"
  end
end
