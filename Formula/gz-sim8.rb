class GzSim8 < Formula
  desc "Gazebo Sim robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sim/releases/gz-sim-8.9.0.tar.bz2"
  sha256 "c55aa45a4f12ddad7115455722afd2fe9bb7fef7cc3fa119a2a24ea77e58dedf"
  license "Apache-2.0"
  revision 16

  head "https://github.com/gazebosim/gz-sim.git", branch: "gz-sim8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "7ea1b1053044dd0884f9ea5ae5c95c1186ccc2b762cacf148d9d6e7cc1a74f0c"
    sha256 arm64_sonoma:  "81d4efb039725fb37df933b32c388ad11bb1eb9c1eb3118d5d79cb8f0eff5ea8"
    sha256 sonoma:        "1752c43636a98efc955bcd2c469cc5cba47fcafb94f6a85e6fefdeeef7e21c91"
  end

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "python@3.13" => [:build, :test]
  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-fuel-tools9"
  depends_on "gz-gui8"
  depends_on "gz-math7"
  depends_on "gz-msgs10"
  depends_on "gz-physics7"
  depends_on "gz-plugin2"
  depends_on "gz-rendering8"
  depends_on "gz-sensors8"
  depends_on "gz-tools2"
  depends_on "gz-transport13"
  depends_on "gz-utils2"
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "ruby"
  depends_on "sdformat14"
  depends_on "tinyxml2"

  def pythons
    deps.map(&:to_formula)
        .select { |f| f.name.match?(/^python@3\.\d+$/) }
  end

  def python_cmake_arg(python = Formula["python@3.13"])
    "-DPython3_EXECUTABLE=#{python.opt_libexec}/bin/python"
  end

  patch do
    # Fix for compatibility with protobuf 30
    url "https://github.com/gazebosim/gz-sim/commit/e727b18373de158bd67e0ba89d57c8458d6c33a8.patch?full_index=1"
    sha256 "d05b5b8d96f997596520381ef1d54c3fd3077e1f541c459c033b37a8328b5c0b"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-sim-8/plugins", target: lib),
      rpath(source: lib/"gz-sim-8/plugins/gui", target: lib),
      rpath(source: lib/"gz-sim-8/plugins/gui/GzSim", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"
    cmake_args << python_cmake_arg

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # install to site-packages of first python version in dependency list
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
      plugin_info.call lib/"gz-sim-8/plugins/libgz-sim-#{system}-system.dylib"
    end
    ["libAlignTool", "libEntityContextMenuPlugin", "libGzSceneManager", "GzSim/libEntityContextMenu"].each do |p|
      plugin_info.call lib/"gz-sim-8/plugins/gui/#{p}.dylib"
    end
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
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-sim8 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sim8::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "gz-sim8"
    # cflags   = `pkg-config --cflags gz-sim8`.split
    # ldflags  = `pkg-config --libs gz-sim8`.split
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
    # check python import
    pythons.each do |python|
      system python.opt_libexec/"bin/python", "-c", "import gz.sim8"
    end
  end
end
