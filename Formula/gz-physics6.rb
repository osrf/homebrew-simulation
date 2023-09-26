class GzPhysics6 < Formula
  desc "Physics library for robotics applications"
  homepage "https://github.com/gazebosim/gz-physics"
  url "https://osrf-distributions.s3.amazonaws.com/gz-physics/releases/gz-physics-6.5.1.tar.bz2"
  sha256 "6556a066f88e48eb3a5d9219245b988e02778ce8c1f90cceb9359e87cbced828"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-physics.git", branch: "gz-physics6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "2a2ddc047ebbb1d413ae87844572d6be59e657e76f7ef4d3ac5da66f21f9acd5"
    sha256 monterey: "0f0aefaddd5545fcc3b7eb0f01ec278466f0d32f0ebdcea187a7967750ed26cd"
    sha256 big_sur:  "3da98f2f48f3e0f0a94fe9c405803e1ad54419041f3fed61b3f8d46969c913fc"
  end

  depends_on "cmake" => [:build, :test]

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
    rpaths = [
      rpath,
      rpath(source: lib/"gz-physics-6/engine-plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test plugins in subfolders
    %w[bullet-featherstone bullet dartsim tpe].each do |engine|
      p = lib/"gz-physics-6/engine-plugins/libgz-physics-#{engine}-plugin.dylib"
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
