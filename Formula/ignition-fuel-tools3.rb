class IgnitionFuelTools3 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools3-3.1.0~pre1.tar.bz2"
  version "3.1.0~pre1"
  sha256 "3c307821a05e36ae3ad634bf927cef170897913bd4080df780f0834f77fe35b4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "86b65412707cd2dbe2e47c73bdfed206bdf9ee9c7c212ce1be594aa03de868ba" => :mojave
    sha256 "fb2c27e25a49ec997467dbae0a572a545326192e14d22b23d9c170d1727a4672" => :high_sierra
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on :macos => :high_sierra # c++17
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
      find_package(ignition-fuel_tools3 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools3::ignition-fuel_tools3)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools3"
    cflags = `pkg-config --cflags ignition-fuel_tools3`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools3",
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
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
