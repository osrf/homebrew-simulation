class IgnitionGui < Formula
  desc "Common libraries for robotics applications. GUI library"
  homepage "https://bitbucket.org/ignitionrobotics/ign-gui"

  head "https://bitbucket.org/ignitionrobotics/ign-gui", :branch => "default", :using => :hg

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
      #include <ignition/gui/Plugin.hh>
      int main() {
        ignition::gui::Plugin foo;

        return 0;
      }
    EOS
    system "pkg-config", "ignition-gui0"
    cflags = `pkg-config --cflags ignition-gui0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-gui0",
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
