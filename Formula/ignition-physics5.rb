class IgnitionPhysics5 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics5-5.3.2.tar.bz2"
  sha256 "4262512fbb6952712234c5cbeed69cdabca338931bb6c587a1ef7d487a5f262b"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-physics.git", branch: "ign-physics5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "3a7d33dfa15c5efeababcb7624020b2b81d41ddac2605e18bede38259cbf0720"
    sha256 cellar: :any, monterey: "c851366911cecb5e466c8c4db15a0b9b927b84aff5824b8a8094222573bf861c"
    sha256 cellar: :any, big_sur:  "21c3de8c60cb2ca1bdefbfb7306f26cffa1acf91583d0053fcf42c6ed7e30e19"
  end

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on "ignition-utils1"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat12"

  patch do
    # Fix for unregistering dartsim collision detector
    url "https://github.com/gazebosim/gz-physics/commit/2c238fe87b7c5ebd3d1ba37784db39ce93a6f143.patch?full_index=1"
    sha256 "396557d48ae665c9a99ea0d9f60308a9ebb08198098df88a7f8497619ffb15d2"
  end

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
    # Disable test due to gazebosim/gz-physics#442
    # system "./test"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
