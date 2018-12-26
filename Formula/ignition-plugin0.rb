class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "http://gazebosim.org/distributions/ign-plugin/releases/ignition-plugin-1.0.0~pre2.tar.bz2"
  version "1.0.0~pre2"
  sha256 "729af670a26472e50b92d67da4a80c9f83f024b6806ddc7a88697ee8275ece0b"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    cellar :any
    sha256 "8bab9824aa1e5a1bd6e11e9b9408fe6ff911cb33db3e201936d3f0e27e883398" => :mojave
    sha256 "4c9f8cb01899c3871237e36c0394f513d3c5209104d821b87cbe1170860dc4a4" => :high_sierra
    sha256 "1488ce3c65c2131d8e46aae8cccbefa0fe6836a8b164c3db9cd126dfd091fa13" => :sierra
    sha256 "813f6a21a9f722cb1ca605e4d1703e77ea753ae2c9e43ed0c3393b69ec902719" => :el_capitan
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
