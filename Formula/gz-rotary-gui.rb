class GzRotaryGui < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://github.com/gazebosim/gz-gui"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-gui.git", branch: "main"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "abseil"
  depends_on "fmt"
  depends_on "gz-rotary-cmake"
  depends_on "gz-rotary-common"
  depends_on "gz-rotary-math"
  depends_on "gz-rotary-msgs"
  depends_on "gz-rotary-plugin"
  depends_on "gz-rotary-rendering"
  depends_on "gz-rotary-transport"
  depends_on "gz-rotary-utils"
  depends_on "protobuf"
  depends_on "qt@6"
  depends_on "qtbase"
  depends_on "qtdeclarative"
  depends_on "spdlog"
  depends_on "tinyxml2"

  conflicts_with "gz-jetty-gui", because: "both install gz-gui"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-gui-10/plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

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

    # test some plugins in subfolders
    %w[CameraFps Publisher TopicViewer WorldStats].each do |plugin|
      p = lib/"gz-gui-10/plugins/lib#{plugin}.dylib"
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
    (testpath/"test.cpp").write <<-EOS
    #include <iostream>

    #ifndef Q_MOC_RUN
      #include <gz/gui/qt.h>
      #include <gz/gui/Application.hh>
      #include <gz/gui/MainWindow.hh>
    #endif

    //////////////////////////////////////////////////
    int main(int _argc, char **_argv)
    {
      std::cout << "Hello, GUI!" << std::endl;

      // Increase verboosity so we see all messages
      gz::common::Console::SetVerbosity(4);

      // Create app
      gz::gui::Application app(_argc, _argv);

      // Load plugins / config
      if (!app.LoadPlugin("Publisher"))
      {
        return 1;
      }

      // Customize main window
      auto win = app.findChild<gz::gui::MainWindow *>()->QuickWindow();
      win->setProperty("title", "Hello Window!");

      // Run window
      // app.exec();

      std::cout << "After run" << std::endl;

      return 0;
    }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-gui QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-gui::gz-gui)
    EOS
    # system "pkg-config", "gz-gui", "--cflags"
    # system "pkg-config", "gz-gui", "--libs"
    # cflags   = `pkg-config --cflags gz-gui`.split
    # ldflags  = `pkg-config --libs gz-gui`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-lc++",
    #                "-o", "test"
    ENV["GZ_PARTITION"] = rand((1 << 32) - 1).to_s
    # system "./test"
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
