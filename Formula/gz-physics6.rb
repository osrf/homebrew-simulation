class GzPhysics6 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/gz-physics/releases/gz-physics-6.3.2.tar.bz2"
  sha256 "79fb56314f4f825e3a6d220d5bf888e8ee391565e005d69d8b251623a109e680"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "acb86b3e7ea9832b139d0a6ca0fcbab9fd816a231ca70f63b7e4fcb7a6b315a3"
    sha256 cellar: :any, big_sur:  "1d0586293d24f0200bcae7253dc466dd1e219fdf6cb6d7297d552b2b29babe7c"
  end

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "google-benchmark"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-plugin2"
  depends_on "gz-utils2"
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
      #include "gz/plugin/Loader.hh"
      #include "gz/physics/ConstructEmpty.hh"
      #include "gz/physics/RequestEngine.hh"
      int main()
      {
        gz::plugin::Loader loader;
        loader.LoadLib("#{opt_lib}/libgz-physics6-dartsim-plugin.dylib");
        gz::plugin::PluginPtr dartsim =
            loader.Instantiate("gz::physics::dartsim::Plugin");
        using featureList = gz::physics::FeatureList<
            gz::physics::ConstructEmptyWorldFeature>;
        auto engine =
            gz::physics::RequestEngine3d<featureList>::From(dartsim);
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "gz-physics6"
    cflags   = `pkg-config --cflags gz-physics6`.split
    ldflags  = `pkg-config --libs gz-physics6`.split
    system "pkg-config", "gz-plugin2-loader"
    loader_cflags   = `pkg-config --cflags gz-plugin2-loader`.split
    loader_ldflags  = `pkg-config --libs gz-plugin2-loader`.split
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
