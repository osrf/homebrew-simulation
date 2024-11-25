class GzPhysics6 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/gz-physics/releases/gz-physics-6.7.0.tar.bz2"
  sha256 "fbf2320c448c7b9d22034589673d6db17039c308529ae32ca08579349301eaf7"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-physics.git", branch: "gz-physics6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 sonoma:  "93f563516a565f13c0bb31145a3ae703d209b960d4dfea77a286435f4886ff0a"
    sha256 ventura: "27b0d3989e83248abbb4eb61278a20df86c2a4cbe80c8f89625b0fa492923289"
  end

  deprecate! date: "2024-09-30", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]

  depends_on "bullet"
  depends_on "dartsim"
  depends_on "fmt"
  depends_on "google-benchmark"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-plugin2"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "pkg-config"
  depends_on "sdformat13"
  depends_on "tinyxml2"
  depends_on "urdfdom"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-physics-6/engine-plugins", target: lib),
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
      p = lib/"gz-physics-6/engine-plugins/libgz-physics-#{engine}-plugin.dylib"
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
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(gz-physics6 REQUIRED)
      find_package(gz-plugin2 REQUIRED COMPONENTS all)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake
          gz-physics6::gz-physics6
          gz-plugin2::loader)
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
