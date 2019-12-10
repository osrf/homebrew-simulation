class IgnitionFuelTools4 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools4-4.0.0.tar.bz2"
  sha256 "f989476d8a54d7b9574cfeed0aafd7bf0a40d892f5d06ae6a97c63ad03ed8196"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "e0dd65d54fefa8e028f14ed8bde24c3a2ea35d9773053e8e61f17392972fd61d" => :mojave
    sha256 "3249b6401131f609feb8ea24362e33908acff16e7f8dada4525cf63742048094" => :high_sierra
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-msgs5"
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
      find_package(ignition-fuel_tools4 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools4::ignition-fuel_tools4)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools4"
    cflags = `pkg-config --cflags ignition-fuel_tools4`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools4",
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
