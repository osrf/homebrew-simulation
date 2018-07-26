class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "https://bitbucket.org/ignitionrobotics/ign-plugin/get/0040d054faaac98fd1bf74b87bf9a673f84a4df8.tar.gz"
  version "0.0.999~20180723~0040d05"
  sha256 "59333fdb43e6a263db5e7cf779929e7d94ff50686473af9003e96fec6731fcdb"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    sha256 "a663808c0808f97fd8f16e784bb52e4ecd9851ac96a69aed7cf8af91c42ace86" => :high_sierra
    sha256 "7008c61aa2aa5c90688169e4c4b698d06f111b3123a44c2f3b04937152b8611b" => :sierra
    sha256 "18c74ee8f0984357fc65c7d09a2e452912ea54338df5aed120944f331bf4a276" => :el_capitan
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
    system "pkg-config", "ignition-plugin0"
    # cflags = `pkg-config --cflags ignition-plugin0`.split(" ")
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                "-L#{lib}",
    #                "-lignition-plugin0",
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
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
