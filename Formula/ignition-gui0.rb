class IgnitionGui0 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "http://gazebosim.org/distributions/ign-gui/releases/ignition-gui0-0.1.0.tar.bz2"
  sha256 "3bed23af1cf5e680cf4ec3fc9bd857d0f9ad02232f17d6b37aedc65be9aac0ab"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "e1b6bada8611d2d56db902dcba35777e2e14fa63cc2d1d1e3bbb291182b37459" => :mojave
    sha256 "39362147784098119b8c692c2a0d094cc4e96526167124504fc79cc4a99dfbb7" => :high_sierra
    sha256 "2da950175cf6b9293deded62b81e652101bd933ee0f627179379eef6e65e90a9" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "ignition-cmake1"
  depends_on "ignition-common2"
  depends_on "ignition-msgs2"
  depends_on "ignition-rendering0"
  depends_on "ignition-transport5"
  depends_on "pkg-config"
  depends_on "qt"
  depends_on "qwt"
  depends_on "tinyxml2"

  # fix pkg-config file to find Qt
  patch do
    url "https://bitbucket.org/ignitionrobotics/ign-gui/commits/353611675f42e7c3a11b339240f83fe97be3ce24/raw/"
    sha256 "7a56b7083cc1bc016f876545ee3a9e864295fab6b5bdeb139e7448d77ae971f4"
  end

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
