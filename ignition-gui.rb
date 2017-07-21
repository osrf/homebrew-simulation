class IgnitionGui < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "https://bitbucket.org/ignitionrobotics/ign-gui/get/f75a3fb765c79a7deb0c2c783d56afc89aa5ac71.tar.gz"
  version "0.0.0-20170719-f75a3fb"
  sha256 "43ba7f421d942c5dfb8c7944345bc44de85f5c595595dc1a81b2dba4b70c836a"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-gui/releases"
    sha256 "1234567890123456789012345678901234567890123456789012345678901234" => :sierra
    sha256 "1234567890123456789012345678901234567890123456789012345678901234" => :el_capitan
    sha256 "1234567890123456789012345678901234567890123456789012345678901234" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "qt5"
  depends_on "qwt"
  depends_on "tinyxml"
  depends_on "ignition-common"
  depends_on "ignition-transport3"

  depends_on "pkg-config" => :run

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
    (testpath/"test.cpp").write <<-EOS.undent
    #include <iostream>
    #include <ignition/gui/qt.h>
    #include <ignition/gui/Iface.hh>

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
    system "pkg-config", "ignition-gui"
    cflags   = `pkg-config --cflags ignition-gui`.split(" ")
    ldflags  = `pkg-config --libs ignition-gui`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
