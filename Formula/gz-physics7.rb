class GzPhysics7 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/gz-physics/releases/gz-physics-7.0.0~pre2.tar.bz2"
  version "7.0.0~pre2"
  sha256 "0b22a00e83959ca63ae4c4321ef5e1a6ca0ca95d9ba099d9623d803ee3afd5b9"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "138a13d619aa00fce5ab113bc85f2ee8c4c48652618645543683e3b8385ad855"
    sha256 monterey: "ae9b15422b6f10492c4acdb6b59c74a0b8fae1b5064a45e7f87190160a7f41fe"
    sha256 big_sur:  "265a4de73a656256c5aecb1a0f63579fa9515d9f260a3688eed22240f1b4fa30"
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
  depends_on "sdformat14"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-physics-7/engine-plugins", target: lib),
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
    ["bullet-featherstone", "bullet", "dartsim", "tpe"].each do |engine|
      p = lib/"gz-physics-7/engine-plugins/libgz-physics-#{engine}-plugin.dylib"
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
      #include "gz/plugin/Loader.hh"
      #include "gz/physics/ConstructEmpty.hh"
      #include "gz/physics/RequestEngine.hh"
      int main()
      {
        gz::plugin::Loader loader;
        loader.LoadLib("#{opt_lib}/libgz-physics7-dartsim-plugin.dylib");
        gz::plugin::PluginPtr dartsim =
            loader.Instantiate("gz::physics::dartsim::Plugin");
        using featureList = gz::physics::FeatureList<
            gz::physics::ConstructEmptyWorldFeature>;
        auto engine =
            gz::physics::RequestEngine3d<featureList>::From(dartsim);
        return engine == nullptr;
      }
    EOS
    system "pkg-config", "gz-physics7"
    cflags   = `pkg-config --cflags gz-physics7`.split
    ldflags  = `pkg-config --libs gz-physics7`.split
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
