class GzRendering9 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://gazebosim.org"
  url "https://github.com/gazebosim/gz-rendering.git", branch: "main"
  version "8.999.999-0-20231016"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "main"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "freeimage"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-math8"
  depends_on "gz-plugin3"
  depends_on "gz-utils3"
  depends_on macos: :mojave # c++17
  depends_on "ogre1.9"
  depends_on "ogre2.3"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-rendering-9/engine-plugins", target: lib),
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
    require "system_command"
    extend SystemCommand::Mixin
    # test plugins in subfolders
    ["ogre", "ogre2"].each do |engine|
      p = lib/"gz-rendering-9/engine-plugins/libgz-rendering-#{engine}.dylib"
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
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(gz-rendering9 REQUIRED COMPONENTS ogre ogre2)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-rendering9::gz-rendering9)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-rendering9"
    cflags   = `pkg-config --cflags gz-rendering9`.split
    ldflags  = `pkg-config --libs gz-rendering9`.split
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
