class IgnitionPhysics5 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics5-5.0.0~pre1.tar.bz2"
  version "5.0.0~pre1"
  sha256 "7d6730ae4224f0b810942773ac893f49e66a90055972960f510836f930c9e9de"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "faaa08eb311fb71f91f67a4dfa7883a8922cdcbab5a7d3f914fac63ddede2567"
    sha256 cellar: :any, catalina: "f8f3e6e93c31e8040735dc42e003b6055265ff932c7ef84ac993d276503975a8"
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
  depends_on "sdformat12"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
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
        loader.LoadLib("#{opt_lib}/libignition-physics5-dartsim-plugin.dylib");
        ignition::plugin::PluginPtr dartsim =
            loader.Instantiate("ignition::physics::dartsim::Plugin");
        using featureList = ignition::physics::FeatureList<
            ignition::physics::ConstructEmptyWorldFeature>;
        auto engine =
            ignition::physics::RequestEngine3d<featureList>::From(dartsim);
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "ignition-physics5"
    cflags   = `pkg-config --cflags ignition-physics5`.split
    ldflags  = `pkg-config --libs ignition-physics5`.split
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
