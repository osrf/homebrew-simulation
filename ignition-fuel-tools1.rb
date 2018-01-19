class IgnitionFuelTools1 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel_tools-1.0.0~pre1.tar.bz2"
  version "1.0.0~pre1"
  sha256 "f08924998d82c95b195d3bd72773a3288d978239671d7f1733ab9007deacfa8f"
  version_scheme 1

  bottle do
    root_url "http://gazebosim.org/distributions/ign-fuel-tools/releases"
    sha256 "797425b88adb94256f5c15b409c5c122f32413a67afa8a2af83add256d13fcaf" => :high_sierra
    sha256 "651f8b58f2bdb43755dd5a62c53e6b883b3f5d399e7e28459bdb21b6161beea6" => :sierra
    sha256 "7e13fe6b088be88127cdde433fd63cf299a4e06aa11fad068e7163353b4bfcaa" => :el_capitan
  end

  depends_on "cmake" => :run
  depends_on "ignition-cmake0"
  depends_on "ignition-common1"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "pkg-config" => :run

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
      find_package(ignition-fuel_tools1 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-FUEL_TOOLS_LIBRARIES})
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools1"
    cflags = `pkg-config --cflags ignition-fuel_tools1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools1",
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
