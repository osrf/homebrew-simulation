class IgnitionGui0 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "https://bitbucket.org/ignitionrobotics/ign-gui/get/9df8a06ef680ee21982a94cb4d9cd56e7a854fd6.tar.gz"
  version "0.1.999~20190711~9df8a06e"
  sha256 "a4e2873aabea8d9c1b77f077a510f05b6ecb07521665a5c2e073c8921fc341eb"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "28be9667929831369ca0eb61c649f7b00fe8688e002b60433a7dd9141a6fab36" => :mojave
    sha256 "df493d10138399089348ccc4b1f5cc37bb5e82e6953b0538d456288f5ccf7e18" => :high_sierra
    sha256 "07ed1503b63dab511b63b096545b980d892dac258a093b57d71c7c92c70fa194" => :sierra
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-math6"
  depends_on "ignition-msgs2"
  depends_on "ignition-rendering2"
  depends_on "ignition-transport5"
  depends_on :macos => :high_sierra # c++17
  depends_on "qt"
  depends_on "qwt"
  depends_on "tinyxml2"

  # conflicts_with "cartr/qt4/qt@4", :because => "Differing versions of qt"

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
    #include <ignition/gui/qt.h>
    #include <ignition/gui/Iface.hh>
    #include <ignition/gui/MainWindow.hh>

    using namespace ignition;
    using namespace gui;

    //////////////////////////////////////////////////
    int main(int _argc, char **_argv)
    {
      std::cout << "Hello, GUI!" << std::endl;
      // Increase verboosity so we see all messages
      setVerbosity(4);
      // Initialize app
      initApp();
      // Create main window
      createMainWindow();
      // Customize main window
      auto win = mainWindow();
      win->setWindowTitle("Hello Window!");
      // After window is closed
      stop();
      std::cout << "After run" << std::endl;

      return 0;
    }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-gui0 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gui0::ignition-gui0)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-gui0"
    cflags   = `pkg-config --cflags ignition-gui0`.split(" ")
    ldflags  = `pkg-config --libs ignition-gui0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    ENV["IGN_PARTITION"] = rand((1 << 32) - 1).to_s
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
