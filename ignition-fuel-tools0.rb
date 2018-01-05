class IgnitionFuelTools0 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel-tools-0.1.3.tar.bz2"
  sha256 "b1cf793a6ad32e7ba9ebe63c9c77602456cbbc1066f3f04a7efd58d10372f676"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-fuel-tools/releases"
    sha256 "07365d4566a658470415f319762ec6cc0c2527a968d0c97ab49c38d4baacc56b" => :high_sierra
    sha256 "ce243b22708e0d7cd789c131a0dd8173ec59b281cad38d65e2a46d659a6b8b0e" => :sierra
    sha256 "e61710fc2fa616ebad4e00287e4fb10cd9765ac758b18565f1950aaff7d9803c" => :el_capitan
  end

  depends_on "cmake" => :run
  depends_on "ignition-common0"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "pkg-config" => :run

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <ignition/fuel-tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS.undent
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel-tools0 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL-TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL-TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-FUEL-TOOLS_LIBRARIES})
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel-tools0"
    cflags = `pkg-config --cflags ignition-fuel-tools0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel-tools0",
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
