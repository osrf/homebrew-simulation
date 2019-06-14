class IgnitionFuelTools3 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-fuel-tools/releases/ignition-fuel-tools3-3.2.0.tar.bz2"
  sha256 "336364f50e854ee868abdccf70d6e31d48fb33a6046c7c3946d30c6d739b34fd"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "7ed5321a0d4ec808dbd46f0067fe37a8f302452dfd3454c8f3399d6da7b8c0e4" => :mojave
    sha256 "7b036c1f803565db6af305e5511ab4f599678aa498ce4822abefc04fe2112bc8" => :high_sierra
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
