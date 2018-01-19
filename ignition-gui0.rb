class IgnitionGui0 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"
  url "https://bitbucket.org/ignitionrobotics/ign-gui/get/374ce9331bd8980f8ff0d150beaaf8fc2baae57d.tar.gz"
  version "0.0.0~20170721~374ce93"
  sha256 "0b77737fe332f8479965c9d4ab2582bc025135674aaf7c63d0270ef205aa9878"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "default", :using => :hg

  # bottle do
  #   rebuild 1
  #   root_url "http://gazebosim.org/distributions/ign-gui/releases"
  #   sha256 "a435130d701ebdaa58bd29833a26d53c612ae2163a195b0124ad71f0e54675d8" => :high_sierra
  #   sha256 "8660bbd506869aebc3c01114af9fa651d4ee67eaa9259748a7fc4204aeb01c08" => :sierra
  #   sha256 "ab9346c2e57d496cc71275d44f6091c6e0792913ca5cc1c88af97e5f099bb37a" => :el_capitan
  # end

  depends_on "cmake" => :build

  depends_on "qt"
  depends_on "qwt"
  depends_on "tinyxml2"
  depends_on "ignition-common1"
  depends_on "ignition-msgs1"
  depends_on "ignition-rendering0"
  depends_on "ignition-transport4"

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
    (testpath/"test.cpp").write <<-EOS
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
