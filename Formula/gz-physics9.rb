class GzPhysics9 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/gz-physics/releases/gz-physics-9.0.0~pre1.tar.bz2"
  version "9.0.0-pre1"
  sha256 "576a57ba7c58351b6e9cd09b11ce9435c52ec08f3674e58f2eb707249b75f8f3"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-physics.git", branch: "gz-physics9"

  depends_on "cmake" => [:build, :test]

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "google-benchmark"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-math9"
  depends_on "gz-plugin4"
  depends_on "gz-utils4"
  depends_on macos: :mojave # c++17
  depends_on "pkgconf"
  depends_on "sdformat16"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-physics-9/engine-plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
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
      p = lib/"gz-physics-9/engine-plugins/libgz-physics-#{engine}-plugin.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin4"].opt_libexec/"gz/plugin4/gz-plugin"
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
        loader.LoadLib("#{opt_lib}/libgz-physics-dartsim-plugin.dylib");
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
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-physics REQUIRED)
      find_package(gz-plugin REQUIRED COMPONENTS all)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake
          gz-physics::gz-physics
          gz-plugin::loader)
    EOS
    system "pkg-config", "gz-physics"
    cflags   = `pkg-config --cflags gz-physics`.split
    ldflags  = `pkg-config --libs gz-physics`.split
    system "pkg-config", "gz-plugin-loader"
    loader_cflags   = `pkg-config --cflags gz-plugin-loader`.split
    loader_ldflags  = `pkg-config --libs gz-plugin-loader`.split
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
