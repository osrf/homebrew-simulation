class GzPhysics8 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/gz-physics/releases/gz-physics-8.3.0.tar.bz2"
  sha256 "ca274cca45c2d6808f4aa09ad01ba6ce17b50a28f71d83dbd8c38b6621c61ef2"
  license "Apache-2.0"
  revision 7

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "6c6a73e3bb47a9dabcfb065c4dfb563b5d29d5c8b18e7cbb3e894719ab20ad3f"
    sha256 arm64_sonoma:  "46880cf7310af66a424685250a4cbbecd563ca101235e00e30d66fc9cd1d319e"
    sha256 sonoma:        "bfd3175b6cec7c9e541266dfdf971b664a9c5d1abb1b77e59cb6a92e25b3b58f"
  end

  # head "https://github.com/gazebosim/gz-physics.git", branch: "gz-physics8"

  depends_on "cmake" => [:build, :test]

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "google-benchmark"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-math8"
  depends_on "gz-plugin3"
  depends_on "gz-utils3"
  depends_on "pkgconf"
  depends_on "sdformat15"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-physics-8/engine-plugins", target: lib),
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
      p = lib/"gz-physics-8/engine-plugins/libgz-physics-#{engine}-plugin.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin3"].opt_libexec/"gz/plugin3/gz-plugin"
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
        loader.LoadLib("#{opt_lib}/libgz-physics8-dartsim-plugin.dylib");
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
      find_package(gz-physics8 REQUIRED)
      find_package(gz-plugin3 REQUIRED COMPONENTS all)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake
          gz-physics8::gz-physics8
          gz-plugin3::loader)
    EOS
    system "pkg-config", "gz-physics8"
    cflags   = `pkg-config --cflags gz-physics8`.split
    ldflags  = `pkg-config --libs gz-physics8`.split
    system "pkg-config", "gz-plugin3-loader"
    loader_cflags   = `pkg-config --cflags gz-plugin3-loader`.split
    loader_ldflags  = `pkg-config --libs gz-plugin3-loader`.split
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
