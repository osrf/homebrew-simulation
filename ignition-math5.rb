class IgnitionMath5 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-math/get/92fc4e757584.tar.gz"
  version "5.0.0~20180817~92fc4e7"
  sha256 "d381633e9302c02220fda97e79fdbe7cb6d5b1d92acbad150322b1cc60219907"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "0640429aa34c438c9713c569cb0d3a16cfd99d7cb3afaeee78f5d8cead4488e1" => :high_sierra
    sha256 "17d32f1a9e341c7ee17cca1dac0502155c30f4b16e6e425d74f36eb2dfc3825c" => :sierra
    sha256 "8f1fc50fbbfa7cb4e8731fe606fe48b578bb2e36e36fb1a58e86520ba96325a8" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "eigen"
  depends_on "ignition-cmake1"

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
      find_package(ignition-math5 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-math5::ignition-math5)
    EOS
    # test building with manual compiler flags
    system ENV.cc, "test.cpp",
                   "--std=c++11",
                   "-I#{include}/ignition/math5",
                   "-L#{lib}",
                   "-lignition-math5",
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
