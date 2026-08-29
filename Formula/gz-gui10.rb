class GzGui10 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://github.com/gazebosim/gz-gui"
  url "https://osrf-distributions.s3.amazonaws.com/gz-gui/releases/gz-gui-10.1.0.tar.bz2"
  sha256 "2bb422b974a783e6fbb8a57c5f0f2d4f7f9802ec3bb2b6766c7b07f00a193ed7"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-gui.git", branch: "gz-gui10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 arm64_sequoia: "d8ddada4b28332d82ec448f203c6e8561a36e59ec61b732bba6e0f4ec074ad56"
    sha256 arm64_sonoma:  "92ae8cee224f5a68961f2d8948b804ea1494e0437884742fb7000974dca5189d"
    sha256 sonoma:        "5c21a82a6d3ee4dc68001cb02742d5bae02a37f90b66b6ad52cc628a1cfc8e8e"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "abseil"
  depends_on "fmt"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-plugin4"
  depends_on "gz-rendering10"
  depends_on "gz-transport15"
  depends_on "gz-utils4"
  depends_on "protobuf"
  depends_on "qt5compat"
  depends_on "qtbase"
  depends_on "qtcharts"
  depends_on "qtdeclarative"
  depends_on "qtlocation"
  depends_on "qtpositioning"
  depends_on "qtsvg"
  depends_on "spdlog"
  depends_on "tinyxml2"

  conflicts_with "gz-rotary-gui", because: "both install gz-gui"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-gui-10/plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    mkdir "build" do
      system "cmake", "-S", "..", "-B", ".", *cmake_args
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
      cmd = formula_opt_libexec("gz-plugin4")/"gz/plugin4/gz-plugin"
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
      system "cmake", "-S", "..", "-B", "."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
