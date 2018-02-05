class IgnitionFuelTools1 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel_tools-1.0.0.tar.bz2"
  sha256 "4266ff5a16db23deffe24a792901c7a28272c198ae9e484b9ec8b2bf6905b5cd"
  version_scheme 1
  revision 1

  bottle do
    root_url "http://gazebosim.org/distributions/ign-fuel-tools/releases"
    sha256 "3f5676a7a90f132faa4a19c043abbe59bef1b49c89f1e002b0cb62be1fe6121e" => :high_sierra
    sha256 "180a49a2f9af22febea099c29320e2b1a63491d13e0170dd7e9f73f89f680a97" => :sierra
    sha256 "4dd898a076147a1fa2face910f69b64993d56bc3527c1506a15dbfd9a5353805" => :el_capitan
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
      target_link_libraries(test_cmake ignition-fuel_tools1::ignition-fuel_tools1)
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
