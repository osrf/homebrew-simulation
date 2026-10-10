class IgnitionRendering6 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/gazebosim/gz-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/gz-rendering/releases/ignition-rendering-6.7.0.tar.bz2"
  sha256 "d3ebc2c56cde7decd8633c4c42a70c16b39b1eb59b10b1ba43de79c470648a8a"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-rendering.git", branch: "ign-rendering6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "45a69be22dd3a12444eddfeff5ea5b59d5ef51c6452b5b75c09a154dabb4bdae"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "gz-plugin2" => :test

  depends_on "freeimage"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on "ignition-utils1"
  depends_on "ogre1.9"
  depends_on "ogre2.2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"ign-rendering-6/engine-plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "-S", "..", "-B", ".", *cmake_args
      system "make", "install"
    end
  end

  test do
    require "system_command"
    extend SystemCommand::Mixin

    ENV["GZ_ENGINE_HEADLESS"] = "1"
    ENV["IGN_ENGINE_HEADLESS"] = "1"
    ENV["QT_QPA_PLATFORM"] = "offscreen"

    # test plugins in subfolders
    ["ogre", "ogre2"].each do |engine|
      p = lib/"ign-rendering-6/engine-plugins/libignition-rendering-#{engine}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = formula_opt_libexec("gz-plugin2")/"gz/plugin2/gz-plugin"
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
      #include <ignition/rendering/RenderEngineManager.hh>
      int main(int _argc, char** _argv)
      {
        ignition::rendering::RenderEngineManager *mgr =
            ignition::rendering::RenderEngineManager::Instance();
        return mgr == nullptr;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-rendering6 REQUIRED COMPONENTS ogre ogre2)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-rendering6::ignition-rendering6)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-rendering6"
    cflags   = `pkg-config --cflags ignition-rendering6`.split
    ldflags  = `pkg-config --libs ignition-rendering6`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", "-S", "..", "-B", "."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
