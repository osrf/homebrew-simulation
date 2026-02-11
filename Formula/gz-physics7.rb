class GzPhysics7 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/gz-physics/releases/gz-physics-7.6.0.tar.bz2"
  sha256 "4b930f61cb02e2cb322f347399b072aa0302d03d88e1788cc38ac719798073fc"
  license "Apache-2.0"
  revision 6

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "a6afbbc113ddffecb9580278e3afed9a4e0b24c836a82d66fe0fde3c69770818"
    sha256 arm64_sonoma:  "7068b97e7c99cd91f76e10277875bc0d2eb5491bec993915c8ce92a4ee9868d1"
    sha256 sonoma:        "59ebb8af95ef6b2e90831ed208116b38a9971c499c2b71913d1f8d0cf66784ad"
  end

  # head "https://github.com/gazebosim/gz-physics.git", branch: "gz-physics7"

  depends_on "cmake" => [:build, :test]

  depends_on "assimp"
  depends_on "bullet"
  depends_on "dartsim"
  depends_on "fcl"
  depends_on "fmt"
  depends_on "google-benchmark"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-plugin2"
  depends_on "gz-utils2"
  depends_on "libccd"
  depends_on "octomap"
  depends_on "ode"
  depends_on "pkgconf"
  depends_on "sdformat14"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-physics-7/engine-plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    require "system_command"
    extend SystemCommand::Mixin

    # test plugins in subfolders
    %w[bullet-featherstone bullet dartsim tpe].each do |engine|
      p = lib/"gz-physics-7/engine-plugins/libgz-physics-#{engine}-plugin.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    end
    # build against API
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
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(gz-physics7 REQUIRED)
      find_package(gz-plugin2 REQUIRED COMPONENTS all)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake
          gz-physics7::gz-physics7
          gz-plugin2::loader)
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
    system "./test"
    # test building with cmake
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
