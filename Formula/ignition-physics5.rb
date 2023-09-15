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
    sha256 cellar: :any, ventura:  "3493a87d1120ffbf9214263f3bf2db615f932b72a75984d2d95011860e81cb8d"
    sha256 cellar: :any, monterey: "58beb1a2a04067bd51db1f412ca0e02360ad7f1ed737aab980d5441f2c0b9db1"
    sha256 cellar: :any, big_sur:  "c9b119681bdf174676192cfdc86a7bc628f3a1b55e97546ed4c58d6a1c2048b3"
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
    rpaths = [
      rpath,
      rpath(source: lib/"ign-physics-5/engine-plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test plugins in subfolders
    ["bullet", "dartsim", "tpe"].each do |engine|
      p = lib/"ign-physics-5/engine-plugins/libignition-physics-#{engine}-plugin.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args: args)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    end
    # build against API
    github_actions = ENV["HOMEBREW_GITHUB_ACTIONS"].present?
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
