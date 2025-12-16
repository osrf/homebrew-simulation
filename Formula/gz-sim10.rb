class GzSim10 < Formula
  desc "Gazebo Sim robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sim/releases/gz-sim-10.0.0.tar.bz2"
  sha256 "d0bb60a902b8d311dbd25e8fc47e0e4bc984ef1b2ed582f62dfa742d879a4c56"
  license "Apache-2.0"
  revision 9

  head "https://github.com/gazebosim/gz-sim.git", branch: "gz-sim10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "da6daf60a99e45d4713196c791ed24802826974b9aab3ad61db1d29bc661222b"
    sha256 arm64_sonoma:  "bcf5d804ec137153da838b871d6de22e1ab38fcc12a98bdf0cca92e3846a8925"
    sha256 sonoma:        "1af128056ddf67becafbe680f6b37e145ecee5b256b8ba4f74121d89266aeb43"
  end

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.14" => [:build, :test]
  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-fuel-tools11"
  depends_on "gz-gui10"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-physics9"
  depends_on "gz-plugin4"
  depends_on "gz-rendering10"
  depends_on "gz-sensors10"
  depends_on "gz-tools2"
  depends_on "gz-transport15"
  depends_on "gz-utils4"
  depends_on "libwebsockets"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "qt@6"
  depends_on "ruby"
  depends_on "sdformat16"
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
    system Formula["gz-tools2"].opt_bin/"gz",
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
