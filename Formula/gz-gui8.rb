class GzGui8 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://github.com/gazebosim/gz-gui"
  url "https://osrf-distributions.s3.amazonaws.com/gz-gui/releases/gz-gui-8.1.1.tar.bz2"
  sha256 "039b8f1025e8a248ecb1875e0ab7fee978e3e282d80b1db7928ec8091ae6556f"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-gui.git", branch: "gz-gui8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "5d90872834b39c5c4df7c49f688dc1d380fc1871d215c5a77786c657dd93f8f5"
    sha256 monterey: "fee49c82ec10d1e3dcb28e4e6f8c90153f1d9ab2ed7462e86ae6b694bf0996f8"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-msgs10"
  depends_on "gz-plugin2"
  depends_on "gz-rendering8"
  depends_on "gz-transport13"
  depends_on macos: :mojave # c++17
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-gui-8/plugins", target: lib),
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
      p = lib/"gz-gui-8/plugins/lib#{plugin}.dylib"
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
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-gui8 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-gui8::gz-gui8)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    system "pkg-config", "gz-gui8"
    cflags   = `pkg-config --cflags gz-gui8`.split
    ldflags  = `pkg-config --libs gz-gui8`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    ENV["GZ_PARTITION"] = rand((1 << 32) - 1).to_s
    system "./test"
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
