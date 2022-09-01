class GzSim7 < Formula
  desc "Gazebo Sim robot simulator"
  homepage "https://github.com/gazebosim/gz-sim"
  url "https://osrf-distributions.s3.amazonaws.com/gz-sim/releases/gz-sim-7.0.0~pre1.tar.bz2"
  version "7.0.0~pre1"
  sha256 "7534f8d03dee7d96965d7efa2467e16ec61526946dcdbc62e61b820559af4b5b"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "25167fa285aa513c9a371eaa084a19709035bbcd736f8715f8a33aad39e047db"
    sha256 catalina: "9caa49f0497d848414d9e34255e5eb01063de6bc081f37501b9efa35df250dff"
  end

  depends_on "cmake" => :build
  depends_on "pybind11" => :build
  depends_on "ffmpeg"
  depends_on "gflags"
  depends_on "google-benchmark"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-fuel-tools8"
  depends_on "gz-gui7"
  depends_on "gz-math7"
  depends_on "gz-msgs9"
  depends_on "gz-physics6"
  depends_on "gz-plugin2"
  depends_on "gz-rendering7"
  depends_on "gz-sensors7"
  depends_on "gz-tools2"
  depends_on "gz-transport12"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "ruby"
  depends_on "sdformat13"

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
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/gz"
    system Formula["ruby"].opt_bin/"ruby",
           Formula["gz-tools2"].opt_bin/"gz",
           "sim", "-s", "--iterations", "5", "-r", "-v", "4"
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
      find_package(gz-sim7 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-sim7::core)
    EOS
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    # system "pkg-config", "--cflags", "gz-sim7"
    # cflags   = `pkg-config --cflags gz-sim7`.split
    # ldflags  = `pkg-config --libs gz-sim7`.split
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
