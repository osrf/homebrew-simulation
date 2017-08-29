class IgnitionGui < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "https://bitbucket.org/ignitionrobotics/ign-gui/get/374ce9331bd8980f8ff0d150beaaf8fc2baae57d.tar.gz"
  version "0.0.0~20170721~374ce93"
  sha256 "0b77737fe332f8479965c9d4ab2582bc025135674aaf7c63d0270ef205aa9878"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-gui/releases"
    sha256 "c18b71d4f1b7e39090798dfc93ac496ec27f990f92e40c23bca213c3919bdfb2" => :sierra
    sha256 "4c014d9e358355e27f7b1a4b856d0fba6d75aba67acdd21d5ea554d2ce5902e2" => :el_capitan
    sha256 "1234567890123456789012345678901234567890123456789012345678901234" => :yosemite
  end

  depends_on "cmake" => :build

  depends_on "qt"
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
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
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
