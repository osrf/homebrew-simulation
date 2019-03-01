class IgnitionMath6 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-math/releases/ignition-math6-6.1.0.tar.bz2"
  sha256 "e72ef72fcfaa509d6f574f83bfc49f0c728ab72b8818bb6e5d4ac9a3e6814b49"

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any
    sha256 "2997f197d5de21626f643c4ebf9625f26bbd75e6884e3bd1f929519233c51304" => :mojave
    sha256 "78042089ae239c0afa65741265c106877bce566084263f0aa5f37484f8353e3e" => :high_sierra
    sha256 "7092b44978d901ea565a0c59c5c7bc3cd25d97327a7ec3da676f45be03a8980a" => :sierra
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "eigen"
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
                   "--std=c++14",
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
