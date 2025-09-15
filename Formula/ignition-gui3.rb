class IgnitionGui3 < Formula
  desc "Common libraries for robotics applications. GUI Library"
  homepage "https://github.com/gazebosim/gz-gui"
  url "https://osrf-distributions.s3.amazonaws.com/gz-gui/releases/ignition-gui-3.12.1.tar.bz2"
  sha256 "47221dba126197f1c40bb4b32e82833db6a46637ede89e84c7849116a9c87aff"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-gui.git", branch: "ign-gui3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 sonoma:  "c3aacc081c0406d6721340135764a94e589d2eb88a439538c7d5107ef08dcdbe"
    sha256 ventura: "b9d9f6bbb1d966e5e8488d51493b726a51b2ee11d40ba22edfe2ef1379e85089"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  disable! date: "2025-09-01", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-msgs5"
  depends_on "ignition-plugin1"
  depends_on "ignition-rendering3"
  depends_on "ignition-transport8"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"ign-gui-3/plugins", target: lib),
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
      find_package(ignition-gui3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-gui3::ignition-gui3)
    EOS
    ENV.append_path "PKG_CONFIG_PATH", Formula["qt@5"].opt_lib/"pkgconfig"
    system "pkg-config", "ignition-gui3"
    cflags   = `pkg-config --cflags ignition-gui3`.split
    ldflags  = `pkg-config --libs ignition-gui3`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    ENV["IGN_PARTITION"] = rand((1 << 32) - 1).to_s
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
