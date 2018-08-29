class IgnitionMath5 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math5-5.0.0~pre4.tar.bz2"
  version "5.0.0~pre4"
  sha256 "b500b4f117ac98de9d078af8fb32ac8f5df85626a0a1297e140c2f5e931a2e77"
  version_scheme 1
  
  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "394b0d8370daf3cfee902f0c3a8178519be39685eeb55391b92d039e0db108b7" => :high_sierra
    sha256 "f47d34b37ac933d24a2c8824de3784d8ee49efcb6e7ce29b1513402c02ceeaa8" => :sierra
    sha256 "8895b002eca170ed4102240c121d1ad90a914fc08f583d1f0988b1735ead2fc8" => :el_capitan
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
