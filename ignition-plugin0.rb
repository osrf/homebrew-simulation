class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "https://bitbucket.org/ignitionrobotics/ign-plugin/get/0640dcb6f62fd2c58a720d2328203b0798c7e61d.tar.gz"
  version "0.1.0~pre3"
  sha256 "2ee4554d5f8dc120faa9e5d71974f663bc45356d7e04b2d943cc22c95169ad6b"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    sha256 "21be33300953dd40e33e1f123a71df6e34b270237653e58ccaf56ac539972237" => :high_sierra
    sha256 "d71854aed01a81bdac32cd6af71142736b6af5f8c45aa86b932107f4a6b14f30" => :sierra
    sha256 "e4e5d8b799bc92e6667716878e7d3e8d18eaa71c1591908672853d2d00bc5dfa" => :el_capitan
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "pkg-config"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/plugin/Loader.hh>
      int main() {
        ignition::plugin::Loader loader;
        return loader.InterfacesImplemented().size();
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-plugin0 QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-PLUGIN_LIBRARIES})
    EOS
    system "pkg-config", "ignition-plugin0-loader"
    cflags = `pkg-config --cflags ignition-plugin0-loader`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-plugin0-loader",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      ENV.append "LIBRARY_PATH", Formula["gettext"].opt_lib
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
