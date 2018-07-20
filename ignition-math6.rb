class IgnitionMath6 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-math/get/994da159c7a4907fb869580c20ade3a9586b7699.tar.gz"
  version "5.999.999~20180709~994da15"
  sha256 "f20f04510e5e8d7f848e0d3a18f3b6bff26fdad512f56667a3f443650dec0756"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "f2b04ce83aafd5ec408a05d4e16a39ba24e58b2845ab1f6522afc0038beaeb49" => :high_sierra
    sha256 "adcd5b5c04eb63e884bee223928a5ac79c3c0325784ab391964435279020c967" => :sierra
    sha256 "c250c58aff5858c3434e62bd1b9f0ce5a8a42cfd2224518ac6caf8e9a16ecf4c" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ignition-cmake2"

  conflicts_with "ignition-math2", :because => "Symbols collision between the two libraries"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "ignition/math/SignalStats.hh"
      int main() {
        ignition::math::SignalMean mean;
        mean.InsertData(1.0);
        mean.InsertData(-1.0);
        return static_cast<int>(mean.Value());
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-math6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-math6::ignition-math6)
    EOS
    # test building with manual compiler flags
    system ENV.cc, "test.cpp",
                   "--std=c++11",
                   "-I#{include}/ignition/math6",
                   "-L#{lib}",
                   "-lignition-math6",
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
