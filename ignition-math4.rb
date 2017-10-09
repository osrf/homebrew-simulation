class IgnitionMath4 < Formula
  desc "Math API for robotic applications"
  homepage "http://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math4-4.0.0~pre1.tar.bz2"
  version "4.0.0~pre1"
  sha256 "050dae7aa3452a88285b714ca775f83d33bb02e2b6fe89f4b31ead750f8ae120"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "2d23eb987bd4d945064eea7a102c58131d0bae8292c3501a4d9058c7600549d4" => :high_sierra
    sha256 "b62fc346167b789e78293d3c39b7ba377c2c8ecab2e0e4f6c881861941d2bac8" => :sierra
    sha256 "5efeaebcae6b74c03c3f02de4affcec4f3286692497f211f844c852f1894052e" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ignition-cmake0"

  conflicts_with "ignition-math2", :because => "Symbols collision between the two libraries"
  conflicts_with "ignition-math3", :because => "Symbols collision between the two libraries"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include "ignition/math/SignalStats.hh"
      int main() {
        ignition::math::SignalMean mean;
        mean.InsertData(1.0);
        mean.InsertData(-1.0);
        return static_cast<int>(mean.Value());
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS.undent
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-math4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-MATH_LIBRARIES})
    EOS
    # test building with manual compiler flags
    system ENV.cc, "test.cpp",
                   "--std=c++11",
                   "-I#{include}/ignition/math4",
                   "-L#{lib}",
                   "-lignition-math4",
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
