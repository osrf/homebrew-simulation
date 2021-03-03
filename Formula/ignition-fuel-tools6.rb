class IgnitionFuelTools6 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://github.com/ignitionrobotics/ign-fuel-tools/archive/dddb1efec1020b3a12c3137768edda10483459a4.tar.gz"
  version "5.999.999~0~20210221~dddb1e"
  sha256 "55988a3193f710a5fcd4d13dcef1b71a535e35b06340ada04ad829b65ea84db7"
  license "Apache-2.0"
  revision 1

  head "https://github.com/ignitionrobotics/ign-fuel-tools.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "a19d55adc671eade234864c56e43afda56b8b9e137fcc817008b43060e3326e7"
    sha256 cellar: :any, mojave:   "d5a2ae1e6b466f382cf716fdc861bb371df3391164db262f1de80a5ffb5c3220"
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
