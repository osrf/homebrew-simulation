class IgnitionFuelTools0 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel-tools-0.1.2~pre1.tar.bz2"
  version "0.1.2~pre1"
  sha256 "919943db38a6c9560e7726fe6ac6d0b4d2e78f2c4cafa6da868eeb0b09bb11c5"

  depends_on "cmake" => :run
  depends_on "ignition-common0"
  depends_on "jsoncpp"
  depends_on "libzip"
  depends_on "pkg-config" => :run

  patch do
    # use libzip_INCLUDE_DIRS
    url "https://bitbucket.org/ignitionrobotics/ign-fuel-tools/commits/e9aef58901c0950453b4a9765d52d76ad71c1b64/raw/"
    sha256 "9791e37102d9ce858839b0be28242f06cff5fd0e31c07dadf3ef0c12f7049882"
  end

  patch do
    # fix for deps that use ign-cmake
    url "https://bitbucket.org/ignitionrobotics/ign-fuel-tools/commits/99170c9b5161a643b984f4580a066212d7ff1ef9/raw/"
    sha256 "17f9548e4780b51cf34bac674533e05a6aca4d88a3b5e85cd3f9074dcac7d059"
  end

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <ignition/fuel-tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS.undent
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel-tools0 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL-TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL-TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-FUEL-TOOLS_LIBRARIES})
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel-tools0"
    cflags = `pkg-config --cflags ignition-fuel-tools0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel-tools0",
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
