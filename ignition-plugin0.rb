class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "http://gazebosim.org/distributions/ign-plugin/releases/ignition-plugin0-0.2.0~pre1.tar.bz2"
  version "0.2.0~pre1"
  sha256 "9ba562b503c98914ae8ca392db833c6a3f0fec5cc7c56e1229740dd0d0122db9"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    sha256 "21be33300953dd40e33e1f123a71df6e34b270237653e58ccaf56ac539972237" => :high_sierra
    sha256 "d71854aed01a81bdac32cd6af71142736b6af5f8c45aa86b932107f4a6b14f30" => :sierra
    sha256 "e4e5d8b799bc92e6667716878e7d3e8d18eaa71c1591908672853d2d00bc5dfa" => :el_capitan
  end

  depends_on "cmake"
  depends_on "ignition-cmake1"
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
