class IgnitionFuelTools1 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-fuel-tools/releases/ignition-fuel-tools2-2.0.0.tar.bz2"
  sha256 "8560f68fff0e075dcd95aebdb9bccf3fcae64f1011000683c05ac17436ee8824"
  version_scheme 1

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    sha256 "0e281bcd1b5e0740e5adadf24b4ee6f0a4af2d15c4e24c8f414496bdb1141028" => :mojave
    sha256 "bd4d96c7a1af30f714f756725aabc3e142c87f103de4a4c7efa5f9c65841a7c9" => :high_sierra
    sha256 "6fca620fc8e02fd47d02f0338bf9c7e48bd02d55db84a2b91973da83f7c8cc84" => :sierra
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
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools1"
    cflags = `pkg-config --cflags ignition-fuel_tools1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools1",
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
