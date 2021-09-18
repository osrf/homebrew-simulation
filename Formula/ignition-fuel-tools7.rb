class IgnitionFuelTools7 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools7-7.0.0~pre1.tar.bz2"
  version "7.0.0~pre1"
  sha256 "8cb5443a46be3fbc6b231b304535a48891e1f50925d8a91ec4e8a9e7c68cd54a"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "c5da37e1a20b7fb91c58bd4b70413b2f065375b2062c3fc1931c6c227cf2186f"
    sha256 cellar: :any, mojave:   "63a71195d28bc4ae935c21408bb9fc222d67df05df012e6e15ca9dc16b44e476"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-msgs8"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

    mkdir "build" do
      system "cmake", "..", *cmake_args
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
      find_package(ignition-fuel_tools7 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools7::ignition-fuel_tools7)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools7"
    cflags = `pkg-config --cflags ignition-fuel_tools7`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools7",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
