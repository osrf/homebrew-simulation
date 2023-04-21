class IgnitionGazebo6 < Formula
  desc "Ignition Gazebo robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/ign-gazebo/releases/ignition-gazebo6-6.14.0.tar.bz2"
  sha256 "7c516f826c1214dd5079a96975004910ad91a09c53afc14e1f308cdaa4b8e918"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-sim.git", branch: "ign-gazebo6"

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
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
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "python@3.11"
  depends_on "ruby"
  depends_on "sdformat12"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # Disable failing test on Monterey
    if MacOS.version != :monterey
      ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
      system Formula["ruby"].opt_bin/"ruby",
             Formula["ignition-tools"].opt_bin/"ign",
             "gazebo", "-s", "--iterations", "5", "-r", "-v", "4"
    end
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
