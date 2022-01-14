class IgnitionGazebo4 < Formula
  desc "Ignition Gazebo robot simulator"
  homepage "https://github.com/ignitionrobotics/ign-gazebo"
  url "https://osrf-distributions.s3.amazonaws.com/ign-gazebo/releases/ignition-gazebo4-4.14.0.tar.bz2"
  sha256 "42e27fabb995482cc5a0685b930257454ce5db8dd5ebbb41824a6f7c91f7774f"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-gazebo.git", branch: "ign-gazebo4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "d6c20fb47c16e385714e832ffb23d9dcb5af92093335ed054ca01d8061798ace"
    sha256 catalina: "b70835ae70f5eebf72e8a2412c4adfec7041c56910f5ebcd82c05e2f61bee2ea"
  end

  deprecate! date: "2021-12-31", because: "is past end-of-life date"
  disable! date: "2022-02-28", because: "is past end-of-life date"

  depends_on "cmake" => :build
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools5"
  depends_on "ignition-gui4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs6"
  depends_on "ignition-physics3"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering4"
  depends_on "ignition-sensors4"
  depends_on "ignition-tools"
  depends_on "ignition-transport9"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "ruby"
  depends_on "sdformat10"

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
      find_package(ignition-gazebo4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo4::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "ignition-gazebo4"
    # cflags   = `pkg-config --cflags ignition-gazebo4`.split
    # ldflags  = `pkg-config --libs ignition-gazebo4`.split
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
