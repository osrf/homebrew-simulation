class IgnitionMath4 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math4-4.0.0.tar.bz2"
  sha256 "5533d1aca0a87450a6ec4770e489bfe24860e6da843b005e594be264c2d6faa0"

  head "https://bitbucket.org/ignitionrobotics/ign-math", :branch => "default", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-math/releases"
    cellar :any
    sha256 "0a012fad519f0e726f6090c5b7e4fef128a8b66c346109f392f8109f37a14af2" => :high_sierra
    sha256 "a2152c21135fc7e7d887ecfbdf0cb17e612780a6088e5c81c639bdcaaf529fdd" => :sierra
    sha256 "e7c3f313b025c4733bd79cb3a27f54846e910e11c34e12d78e1c054eb06bbd48" => :el_capitan
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ignition-cmake0"

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
      find_package(ignition-math4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-math4::ignition-math4)
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
