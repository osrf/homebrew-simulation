class IgnitionFuelTools0 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel-tools-0.1.3.tar.bz2"
  sha256 "b1cf793a6ad32e7ba9ebe63c9c77602456cbbc1066f3f04a7efd58d10372f676"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-fuel-tools/releases"
    sha256 "0d391694824f6ec25c5398f6335985652739dbda9c52097b5cdffc36dcb4bc35" => :high_sierra
    sha256 "61771e57b63096c4a0621ff754ab482da3cc6c1854e30370a1a39818360bde15" => :sierra
    sha256 "471ae847519ddb4ff62218c3b86a0a14330cf6fb325bbba4ac6ba9d39b1c77f9" => :el_capitan
  end

  depends_on "cmake" => :run
  depends_on "ignition-common1"
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
