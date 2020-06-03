class IgnitionFuelTools1 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools1-1.2.0.tar.bz2"
  sha256 "6b1d631a095e8273dc09be7456758aeaa7582b74bebe983cc14da49063994473"
  revision 4
  version_scheme 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "e09f172beebcbb0af4704bf3b1d06f0d77d84f6ec99960d2243db89b408b4550" => :mojave
    sha256 "c45f016cd301e7f2a0a3e053e3a1cee07c4c6893e8cdc56d93d15419f4257b89" => :high_sierra
    sha256 "83fc73fa6c6d8b09defab433f46af07d8ef59ef886ac9b6992211057faac0ca0" => :sierra
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
    # # test building with pkg-config
    # system "pkg-config", "--cflags", "ignition-fuel_tools1"
    # cflags = `pkg-config --cflags ignition-fuel_tools1`.split(" ")
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                "-L#{lib}",
    #                "-lignition-fuel_tools1",
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
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
