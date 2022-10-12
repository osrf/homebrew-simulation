class GzGui7 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://github.com/gazebosim/gz-gui"
  url "https://osrf-distributions.s3.amazonaws.com/gz-gui/releases/gz-gui-7.0.0.tar.bz2"
  sha256 "da1b431991a7ddf803ffd454007ba2c114747882f502c2c9d1066636b1480bf4"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-gui.git", branch: "gz-gui7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "a720f9aaa07802aa930123a3aa6e9bf24b195d6644fecd4104e5d8a6f534e79d"
    sha256 catalina: "af618c1a74b9da56dba4a10b193f95cb650e96fa1e29aec18eb50bfc9dbb72a5"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-msgs9"
  depends_on "gz-plugin2"
  depends_on "gz-rendering7"
  depends_on "gz-transport12"
  depends_on macos: :mojave # c++17
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
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
      find_package(gz-gui7 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-gui7::gz-gui7)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    system "pkg-config", "gz-gui7"
    cflags   = `pkg-config --cflags gz-gui7`.split
    ldflags  = `pkg-config --libs gz-gui7`.split
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
