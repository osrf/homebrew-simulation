class IgnitionGazebo5 < Formula
  desc "Ignition Gazebo robot simulator"
  homepage "https://github.com/ignitionrobotics/ign-gazebo"
  url "https://github.com/ignitionrobotics/ign-gazebo/archive/4f025873a01e55562895812a2e3850315dda2d87.tar.gz"
  version "4.999.999~0~20210122~4f0258"
  sha256 "05ee0ea0aa27ccb5d4285f5c24f732951bee53b39a6fc98f919106fdebcb9be3"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-gazebo.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "218a378304b01f88304224e86ed2d3b8fe74a4c5559abae125f9589d9bf84bf2"
    sha256 mojave: "f02b854ae36a7bc63e72e1f755edc2759912814b7c2ec6a5e8a4e46a7d81e8d7"
  end

  depends_on "cmake" => :build
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-fuel-tools6"
  depends_on "ignition-gui5"
  depends_on "ignition-math6"
  depends_on "ignition-msgs7"
  depends_on "ignition-physics4"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering5"
  depends_on "ignition-sensors5"
  depends_on "ignition-tools"
  depends_on "ignition-transport10"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "ruby"
  depends_on "sdformat11"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

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
      find_package(ignition-gazebo5 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo5::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "ignition-gazebo5"
    # cflags   = `pkg-config --cflags ignition-gazebo5`.split
    # ldflags  = `pkg-config --libs ignition-gazebo5`.split
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
