class IgnitionFuelTools0 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://github.com/ignitionrobotics/ign-fuel-tools/archive/9b5619bd4e550689047c230222ac8df158a25e99.tar.gz"
  version "0.1.3~20180108~4bf08a71cb"
  sha256 "dce9a2816c797392a3a0c94f0c09bbb8dedd37969d1a9990dc37c61f767bb3e2"
  license "Apache-2.0"

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
      #include <ignition/fuel-tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel-tools0 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL-TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL-TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-FUEL-TOOLS_LIBRARIES})
    EOS
    # # test building with pkg-config
    # system "pkg-config", "--cflags", "ignition-fuel-tools0"
    # cflags = `pkg-config --cflags ignition-fuel-tools0`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                "-L#{lib}",
    #                "-lignition-fuel-tools0",
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
