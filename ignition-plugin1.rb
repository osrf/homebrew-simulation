class IgnitionPlugin1 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "http://gazebosim.org/distributions/ign-plugin/releases/ignition-plugin-1.0.0~pre1.tar.bz2"
  version "1.0.0~pre1"
  sha256 "13eebee797286e6640c5c9a7489760359a0b759ddd81745afffe19b23e4e29f1"
  revision 1

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    cellar :any
    sha256 "883c53ae2662c3803ee4022279d71384f7a2626d1e1691867b9e0082708e6fdc" => :mojave
    sha256 "1037da4b026453b10cabb265655c18cef2fa101fae043368f8270f7264a66db4" => :high_sierra
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on :macos => :high_sierra   # c++17
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
      find_package(ignition-plugin1 QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-PLUGIN_LIBRARIES})
    EOS
    system "pkg-config", "ignition-plugin1-loader"
    cflags = `pkg-config --cflags ignition-plugin1-loader`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-plugin1-loader",
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
