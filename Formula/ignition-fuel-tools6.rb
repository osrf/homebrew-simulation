class IgnitionFuelTools6 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools6-6.0.0.tar.bz2"
  sha256 "cef42468578c32ea9e0e36499dc470ecab23a209f0d9febca1970afa175b5fb1"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-fuel-tools.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "22867ea3a4892b684da678fe397e3d3ded97332e1de6569457bed4179c09b710"
    sha256 cellar: :any, mojave:   "77e8bf09197cb6ff04f1326a8f129cc6f4b501c12ea7f53a3b0282623d6a7950"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-msgs7"
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
      find_package(ignition-fuel_tools6 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools6::ignition-fuel_tools6)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools6"
    cflags = `pkg-config --cflags ignition-fuel_tools6`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools6",
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
