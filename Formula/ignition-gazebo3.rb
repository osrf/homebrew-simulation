class IgnitionGazebo3 < Formula
  desc "Ignition Gazebo robot simulator"
  homepage "https://github.com/ignitionrobotics/ign-gazebo"
  url "https://osrf-distributions.s3.amazonaws.com/ign-gazebo/releases/ignition-gazebo3-3.13.0~pre3.tar.bz2"
  version "3.13.0~pre3"
  sha256 "8c6d80bb23b38ec5b8622591d28c8e6298f28f490f25f33038f983ddba515def"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-gazebo.git", branch: "ign-gazebo3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "01ebae8ea00a61dd28316defe1576692b2523a233bf698ef1d6984a8495fd8ad"
    sha256 catalina: "43c2a0cfa0b21be0773851d499215414c356a26e3eede82af480911eeab62ef0"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  depends_on "cmake" => :build
  depends_on "ffmpeg"
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools4"
  depends_on "ignition-gui3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-physics2"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering3"
  depends_on "ignition-sensors3"
  depends_on "ignition-tools"
  depends_on "ignition-transport8"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "ruby"
  depends_on "sdformat9"

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
      find_package(ignition-gazebo3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gazebo3::core)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "ignition-gazebo3"
    # cflags   = `pkg-config --cflags ignition-gazebo3`.split
    # ldflags  = `pkg-config --libs ignition-gazebo3`.split
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
