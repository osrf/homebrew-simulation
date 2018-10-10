class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "http://gazebosim.org/distributions/ign-plugin/releases/ignition-plugin0-0.2.0~pre1.tar.bz2"
  version "0.2.0~pre1"
  sha256 "9ba562b503c98914ae8ca392db833c6a3f0fec5cc7c56e1229740dd0d0122db9"
  revision 1

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    cellar :any
    sha256 "4f75341d4700b06d527eaf8c7d9a3b3b44854bcef92b48dfea04fe74c97b1f97" => :mojave
    sha256 "ca6d9d9b7400180b06a16c738c1c1aaa0abf441bd8bef3e84eb4066578a675e8" => :high_sierra
    sha256 "7cf67747e18e582bacb60a0fc87ef601fcdbdbbb69771a22ffc6e191a85360c4" => :sierra
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
