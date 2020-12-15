class IgnitionGazebo2 < Formula
  desc "Gazebo robot simulator"
  homepage "https://github.com/ignitionrobotics/ign-gazebo"
  url "https://osrf-distributions.s3.amazonaws.com/ign-gazebo/releases/ignition-gazebo2-2.25.0.tar.bz2"
  sha256 "7d05c1586ef53d67cbf6562f5c7d1bf4480280f5ecb172d235101c40942ee1f9"
  license "Apache-2.0"
  revision 2

  head "https://github.com/ignitionrobotics/ign-gazebo", branch: "ign-gazebo2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "0be73f21beab891fd7ef73d85df055cfe5026f79ce18c38927ced1e84e8998f3" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "gflags"
  depends_on "google-benchmark"
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
  depends_on "ignition-tools"
  depends_on "ignition-transport7"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "ruby"
  depends_on "sdformat8"

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system Formula["ruby"].opt_bin/"ruby",
           Formula["ignition-tools"].opt_bin/"ign",
           "gazebo", "-s", "--iterations", "5", "-r", "-v", "4"
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
    # system "pkg-config", "--cflags", "ignition-gazebo2"
    # cflags   = `pkg-config --cflags ignition-gazebo2`.split(" ")
    # ldflags  = `pkg-config --libs ignition-gazebo2`.split(" ")
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
