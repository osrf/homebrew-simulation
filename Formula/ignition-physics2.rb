class IgnitionPhysics2 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/ign-physics/releases/ignition-physics2-2.6.1.tar.bz2"
  sha256 "036c2b4effec9eefcdc94ac4ae0c6caec15d802db2e20665d76fcf69b7934643"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-physics.git", branch: "gz-physics2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "8d73864060afb088d94d734ab9962b98dbdc8b9d2a625bc140150e89adec6eea"
    sha256 cellar: :any, monterey: "12564bdb4d62912093a42e81aec8e4c0172e4bab0d1cd9baa701dc43c12fa5f4"
    sha256 cellar: :any, big_sur:  "9a868329c347e206992e28a3a590f83c17da673605199727746a515a189c11e5"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  depends_on "cmake" => :build

  depends_on "bullet"
  depends_on "dartsim@6.10.0"
  depends_on "google-benchmark"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat9"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"ign-physics-2/engine-plugins", target: lib),
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
      p = lib/"ign-physics-2/engine-plugins/libignition-physics-#{engine}-plugin.dylib"
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
        loader.LoadLib("#{opt_lib}/libignition-physics2-dartsim-plugin.dylib");
        ignition::plugin::PluginPtr dartsim =
            loader.Instantiate("ignition::physics::dartsim::Plugin");
        using featureList = ignition::physics::FeatureList<
            ignition::physics::ConstructEmptyWorldFeature>;
        auto engine =
            ignition::physics::RequestEngine3d<featureList>::From(dartsim);
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "ignition-physics2"
    cflags   = `pkg-config --cflags ignition-physics2`.split
    ldflags  = `pkg-config --libs ignition-physics2`.split
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
