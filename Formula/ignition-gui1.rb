class IgnitionGui1 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "http://gazebosim.org/distributions/ign-gui/releases/ignition-gui-1.0.0.tar.bz2"
  sha256 "a814c278e51cf6ffc08fbf19a4d417e11a374a8c34456f54ff2354e0423da273"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "gz11", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "672df3ba88f9f835c82860389215035dc6b973b429c9483a93cd120908ea6322" => :mojave
    sha256 "54b9588c91206381d87b499e9c394094cf955071a6a927062a6e589977a35b26" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-msgs3"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering1"
  depends_on "ignition-transport6"
  depends_on :macos => :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "qt"
  depends_on "qwt"
  depends_on "tinyxml2"

  def install
    ENV.m64

    cmake_args = std_cmake_args
    cmake_args << "-DQWT_WIN_INCLUDE_DIR=#{HOMEBREW_PREFIX}/lib/qwt.framework/Headers"
    cmake_args << "-DQWT_WIN_LIBRARY_DIR=#{HOMEBREW_PREFIX}/lib/qwt.framework"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
    #include <iostream>

    #ifndef Q_MOC_RUN
      #include <ignition/gui/qt.h>
      #include <ignition/gui/Application.hh>
      #include <ignition/gui/MainWindow.hh>
    #endif

    //////////////////////////////////////////////////
    int main(int _argc, char **_argv)
    {
      std::cout << "Hello, GUI!" << std::endl;

      // Increase verboosity so we see all messages
      ignition::common::Console::SetVerbosity(4);

      // Create app
      ignition::gui::Application app(_argc, _argv);

      // Load plugins / config
      if (!app.LoadPlugin("Publisher"))
      {
        return 1;
      }

      // Customize main window
      auto win = app.findChild<ignition::gui::MainWindow *>()->QuickWindow();
      win->setProperty("title", "Hello Window!");

      // Run window
      // app.exec();

      std::cout << "After run" << std::endl;

      return 0;
    }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-gui1 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gui1::ignition-gui1)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-gui1"
    cflags   = `pkg-config --cflags ignition-gui1`.split(" ")
    ldflags  = `pkg-config --libs ignition-gui1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["qt"].opt_prefix
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
