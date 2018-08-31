class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "http://gazebosim.org/distributions/ign-plugin/releases/ignition-plugin-0.1.0~pre2.tar.bz2"
  version "0.1.0~pre2"
  sha256 "04efa0e1a5437ae800f770f997bf8ebcbb0f9a415d0565a66bebec7ae570ec9d"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    sha256 "21be33300953dd40e33e1f123a71df6e34b270237653e58ccaf56ac539972237" => :high_sierra
    sha256 "b44e1b267c709bfef211c0ca1863a1096bb87798b9bfe05716fd5d260ae6c48a" => :sierra
    sha256 "e4e5d8b799bc92e6667716878e7d3e8d18eaa71c1591908672853d2d00bc5dfa" => :el_capitan
  end

  depends_on "cmake"
  depends_on "ignition-cmake1"
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
