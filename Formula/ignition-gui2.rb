class IgnitionGui2 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "https://bitbucket.org/ignitionrobotics/ign-gui/get/90726900c6d6e78cccfdc411a49c8fdb4125a2fc.tar.bz2"
  version "1.999.999~20190412~907269"
  sha256 "e46fd75246c041ffdd0a8549cfab8e14ebcc5e77ed6f35debc0fc43a800ef8ea"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "a6b7f906bec21d3c353d590daa21a8500a2bbd6b2a7e5f83f5711c89725859a7" => :mojave
    sha256 "b9259c1fdef7503f7aa6a19ae52a64eefe6ba5ffee63e3857d2e9c148593461c" => :high_sierra
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-msgs4"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering2"
  depends_on "ignition-transport7"
  depends_on :macos => :high_sierra # c++17
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
      find_package(ignition-gui2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gui2::ignition-gui2)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-gui2"
    cflags   = `pkg-config --cflags ignition-gui2`.split(" ")
    ldflags  = `pkg-config --libs ignition-gui2`.split(" ")
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
