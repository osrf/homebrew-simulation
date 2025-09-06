class GzGui10 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://github.com/gazebosim/gz-gui"
  url "https://osrf-distributions.s3.amazonaws.com/gz-gui/releases/gz-gui-10.0.0~pre2.tar.bz2"
  version "10.0.0-pre2"
  sha256 "d8d0ed237ed9f7810b7524e286a0a42b6cedecc74362eb090d12533dcee36a2d"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-gui.git", branch: "gz-gui10"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "abseil"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-plugin4"
  depends_on "gz-rendering10"
  depends_on "gz-transport15"
  depends_on "gz-utils4"
  depends_on macos: :mojave # c++17
  depends_on "protobuf"
  depends_on "qt@6"
  depends_on "tinyxml2"

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

  test do
    require "system_command"
    extend SystemCommand::Mixin
    # test some plugins in subfolders
    %w[CameraFps Publisher TopicViewer WorldStats].each do |plugin|
      p = lib/"gz-gui-10/plugins/lib#{plugin}.dylib"
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
    # ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
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
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt@5"].opt_prefix
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
