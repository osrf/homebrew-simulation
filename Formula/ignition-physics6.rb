class IgnitionPhysics6 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-physics"
  url "https://github.com/ignitionrobotics/ign-physics.git", branch: "main"
  version "5.999.999~0~20220414"
  license "Apache-2.0"

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "google-benchmark"
  depends_on "ignition-cmake3"
  depends_on "ignition-common5"
  depends_on "ignition-math7"
  depends_on "ignition-plugin2"
  depends_on "ignition-utils2"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat13"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "ignition/plugin/Loader.hh"
      #include "ignition/physics/ConstructEmpty.hh"
      #include "ignition/physics/RequestEngine.hh"
      int main()
      {
        ignition::plugin::Loader loader;
        loader.LoadLib("#{opt_lib}/libignition-physics6-dartsim-plugin.dylib");
        ignition::plugin::PluginPtr dartsim =
            loader.Instantiate("ignition::physics::dartsim::Plugin");
        using featureList = ignition::physics::FeatureList<
            ignition::physics::ConstructEmptyWorldFeature>;
        auto engine =
            ignition::physics::RequestEngine3d<featureList>::From(dartsim);
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "ignition-physics6"
    cflags   = `pkg-config --cflags ignition-physics6`.split
    ldflags  = `pkg-config --libs ignition-physics6`.split
    system "pkg-config", "ignition-plugin2-loader"
    loader_cflags   = `pkg-config --cflags ignition-plugin2-loader`.split
    loader_ldflags  = `pkg-config --libs ignition-plugin2-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   *loader_cflags,
                   *loader_ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
