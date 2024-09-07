class GzSim9 < Formula
  desc "Gazebo Sim robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sim/releases/gz-sim-9.0.0~pre1.tar.bz2"
  version "9.0.0-pre1"
  sha256 "3a166af7a15062e10a886df345204bb0cda1d14bda627aaafda128ca57d2d7ab"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-sim.git", branch: "gz-sim9"

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "abseil"
  depends_on "ffmpeg"
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-fuel-tools10"
  depends_on "gz-gui9"
  depends_on "gz-math8"
  depends_on "gz-msgs11"
  depends_on "gz-physics8"
  depends_on "gz-plugin3"
  depends_on "gz-rendering9"
  depends_on "gz-sensors9"
  depends_on "gz-tools2"
  depends_on "gz-transport14"
  depends_on "gz-utils3"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "python@3.12"
  depends_on "qt@5"
  depends_on "ruby"
  depends_on "sdformat15"
  depends_on "tinyxml2"

  def python_cmake_arg
    "-DPython3_EXECUTABLE=#{which("python3")}"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-sim-9/plugins", target: lib),
      rpath(source: lib/"gz-sim-9/plugins/gui", target: lib),
      rpath(source: lib/"gz-sim-9/plugins/gui/GzSim", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"
    cmake_args << python_cmake_arg

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.12/site-packages").install Dir[lib/"python/*"]
    rmdir prefix/"lib/python"
  end

  test do
    require "system_command"
    extend SystemCommand::Mixin
    # test some plugins in subfolders
    plugin_info = lambda { |p|
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin3"].opt_libexec/"gz/plugin3/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    }
    %w[altimeter log physics sensors].each do |system|
      plugin_info.call lib/"gz-sim-9/plugins/libgz-sim-#{system}-system.dylib"
    end
    ["libAlignTool", "libEntityContextMenuPlugin", "libGzSceneManager", "GzSim/libEntityContextMenu"].each do |p|
      plugin_info.call lib/"gz-sim-9/plugins/gui/#{p}.dylib"
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
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-sim9 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sim9::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "gz-sim9"
    # cflags   = `pkg-config --cflags gz-sim9`.split
    # ldflags  = `pkg-config --libs gz-sim9`.split
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
    system Formula["python@3.12"].opt_bin/"python3.12", "-c", "import gz.sim9"
  end
end
