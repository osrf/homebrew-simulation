class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "http://gazebosim.org/distributions/ign-plugin/releases/ignition-plugin-0.1.0~pre1.tar.bz2"
  version "0.1.0~pre1"
  sha256 "645fa5f2baee8f97455b109cc1314b9c686ec2f70d01b6fafbe45111a80a0129"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    sha256 "735c49b73cfe0c123571f232126daf3cc726a39fa9e0d84d2e71fef0c2746d5e" => :high_sierra
    sha256 "d1e10121d4cda181e6f47ad8885bbc0c39d06d93192bf1c9fb11cb746da902b4" => :sierra
    sha256 "1d86b2dd48a0a64f723691846d58a41f39055b1c284751461b564effbd37c38a" => :el_capitan
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
