class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-plugin"
  url "https://bitbucket.org/ignitionrobotics/ign-plugin/get/0040d054faaac98fd1bf74b87bf9a673f84a4df8.tar.gz"
  version "0.0.999~20180723~0040d05"
  sha256 "59333fdb43e6a263db5e7cf779929e7d94ff50686473af9003e96fec6731fcdb"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-plugin/releases"
    sha256 "7e65176beddd592784d0779b98f3c63a19cafda6bf9b1c8b80a75a71538b4081" => :high_sierra
    sha256 "7008c61aa2aa5c90688169e4c4b698d06f111b3123a44c2f3b04937152b8611b" => :sierra
    sha256 "cae42cb31ffd664a1108bc79154ee39697c012cb3dcdf276c8cd139dbd474433" => :el_capitan
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
