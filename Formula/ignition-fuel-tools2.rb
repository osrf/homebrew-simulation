class IgnitionFuelTools2 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel-tools2-2.0.0.tar.bz2"
  sha256 "719a3c0c32afa3a188f74f8c37d53559e35b8bba6743ee6a5e88c299528f81f2"
  revision 1

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "1b3c9420e00cc6434c3027bd4371a8ac9e5876abf4e1c43c92ba35364fa5dfdf" => :mojave
    sha256 "bdf6b0fef12a813697642fe53463bb2e4da55f85f23d1fd5cf1a7fa86dd673d7" => :high_sierra
    sha256 "bd826f66e9fbb18f44630ae549f26ff635b8b36ec0c01095f38e470f001512f9" => :sierra
  end

  depends_on "cmake"
  depends_on "ignition-cmake0"
  depends_on "ignition-common1"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "pkg-config"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/fuel_tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel_tools2 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools2::ignition-fuel_tools2)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools2"
    cflags = `pkg-config --cflags ignition-fuel_tools2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools2",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
