class GzRotaryRendering < Formula
  desc "Rendering library for robotics applications"
  homepage "https://gazebosim.org"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "main"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "fmt"
  depends_on "gz-rotary-cmake"
  depends_on "gz-rotary-common"
  depends_on "gz-rotary-math"
  depends_on "gz-rotary-plugin"
  depends_on "gz-rotary-utils"
  depends_on "ogre1.9"
  depends_on "ogre2.3"
  depends_on "spdlog"

  conflicts_with "gz-jetty-rendering", because: "both install gz-rendering"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-rendering/engine-plugins", target: lib),
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

  def caveats
    <<~EOS
      This is an unstable, development version of Gazebo built from source.
    EOS
  end

  test do
    require "system_command"
    extend SystemCommand::Mixin

    # test plugins in subfolders
    ["ogre", "ogre2"].each do |engine|
      p = lib/"gz-rendering/engine-plugins/libgz-rendering-#{engine}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-rotary-plugin"].opt_libexec/"gz/plugin/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    end
    # build against API
    github_actions = ENV["HOMEBREW_GITHUB_ACTIONS"].present?
    (testpath/"test.cpp").write <<-EOS
      #include <gz/rendering/RenderEngine.hh>
      #include <gz/rendering/RenderingIface.hh>
      int main(int _argc, char** _argv)
      {
        gz::rendering::RenderEngine *engine =
            gz::rendering::engine("ogre");
        return engine == nullptr;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-rendering REQUIRED COMPONENTS ogre ogre2)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-rendering::gz-rendering)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-rendering"
    cflags   = `pkg-config --cflags gz-rendering`.split
    ldflags  = `pkg-config --libs gz-rendering`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test" unless github_actions
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake" unless github_actions
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
