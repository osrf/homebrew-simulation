class IgnitionFuelTools4 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-fuel-tools/get/b575879f76505806621a868898c1a66406c7aa8b.tar.bz2"
  version "3.999.999~20191203~b575879"
  sha256 "32af552eb1112fcb7de00c22f0446797a5fea520e560f5badcbe78ae78071517"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "b1dd7b82810e9244326d5024c830f4a56385067b2b1dab7830a916d135c7cebb" => :mojave
    sha256 "7dceaa03d63044a1decf5fd840779bdbace26e82773c83507a74a9bf7382a1ff" => :high_sierra
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
