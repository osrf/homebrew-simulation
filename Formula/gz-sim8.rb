class GzSim8 < Formula
  desc "Gazebo Sim robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sim/releases/gz-sim-8.0.0~pre1.tar.bz2"
  version "8.0.0~pre1"
  sha256 "acf6d851cb8570bb978b3a56a4c5d0c11f6f75056b163311aa6dfc7fd9833ff4"
  license "Apache-2.0"
  revision 3

  head "https://github.com/gazebosim/gz-sim.git", branch: "gz-sim8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "7630d00cd473903e3aaba1ba472aea9d7f6adb49b5deedafd99d09d1058c6aa2"
    sha256 monterey: "5d81376fb61007e273b247916b2e2f73ffb9b3ae9121badff2e6bc7822e5cf5d"
    sha256 big_sur:  "9b6d8b36f6230dbba5eb54f6ef17bbb6b8e0e7c4a0e297c3e1315c845d409ad5"
  end

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
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
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "ruby"
  depends_on "sdformat14"

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

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test some plugins in subfolders
    plugin_info = lambda { |p|
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args: args)
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
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["ffmpeg@4"].opt_prefix
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
