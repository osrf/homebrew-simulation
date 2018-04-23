class IgnitionFuelTools1 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel_tools-1.0.0.tar.bz2"
  sha256 "4266ff5a16db23deffe24a792901c7a28272c198ae9e484b9ec8b2bf6905b5cd"
  revision 3
  version_scheme 1

  bottle do
    root_url "http://gazebosim.org/distributions/ign-fuel-tools/releases"
    sha256 "4638b1cd2607f088559f7aec1b52e437f1bd69696175079efae2b5c13d05301f" => :high_sierra
    sha256 "25d14a5e923293f2459afe31724be6167767f1d6780160f1d61b551123b74e2a" => :sierra
    sha256 "8dfe5b7c2cf6a6ccc696100527fb3cdab7d21923ee7a0659ceff96d37183de10" => :el_capitan
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
