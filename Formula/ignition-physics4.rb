class IgnitionPhysics4 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics4-4.3.0.tar.bz2"
  sha256 "66efb3f4e4f9f10b591200fea52f4d44297c596d26f8a88f951bb645c6fab7c2"
  license "Apache-2.0"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "8b88318ef686a9dc28a6bc8189ba0390715e142a46fdac30678ace947bcb2dd6"
    sha256 cellar: :any, catalina: "7bd9b00ec3c566c93c8c703ed167bab9da4d52634d3e41daec6dae9054003a5a"
  end

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim@6.10.0"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on "ignition-utils1"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat11"

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
        loader.LoadLib("#{opt_lib}/libignition-physics4-dartsim-plugin.dylib");
        ignition::plugin::PluginPtr dartsim =
            loader.Instantiate("ignition::physics::dartsim::Plugin");
        using featureList = ignition::physics::FeatureList<
            ignition::physics::ConstructEmptyWorldFeature>;
        auto engine =
            ignition::physics::RequestEngine3d<featureList>::From(dartsim);
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "ignition-physics4"
    cflags   = `pkg-config --cflags ignition-physics4`.split
    ldflags  = `pkg-config --libs ignition-physics4`.split
    system "pkg-config", "ignition-plugin1-loader"
    loader_cflags   = `pkg-config --cflags ignition-plugin1-loader`.split
    loader_ldflags  = `pkg-config --libs ignition-plugin1-loader`.split
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
