class IgnitionGui1 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "https://bitbucket.org/ignitionrobotics/ign-gui/get/fae7d4bb536acce627ce971308029ad49cb5fe2a.tar.gz"
  version "1.0.0~pre2~1~fae7d4b"
  sha256 "5c7fc684b83b8ac8db930930353e20abf37f6492d60f730ca3978c5774dd2446"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "gz11", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "2489a47d8f8adca2a0b07d1e6989fa2487baa4fa2f7ca3cb71599b620f9b9811" => :mojave
    sha256 "512f47c998e823b3811eef3ee40d91627591f0c9a069572724c44fcddd748303" => :high_sierra
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
  depends_on "tinyxml2@6.2.0"

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
    ENV.append_path "PKG_CONFIG_PATH", Formula["tinyxml2@6.2.0"].opt_lib/"pkgconfig"
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
