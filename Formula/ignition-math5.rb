class IgnitionMath5 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-math/releases/ignition-math5-5.1.0.tar.bz2"
  sha256 "f28aa11f8f292e70cc8a0427452fa4548390408ec9b6df88d5b221dde0d42d1c"
  license "Apache-2.0"
  version_scheme 1

  head "https://github.com/ignitionrobotics/ign-math.git", branch: "ign-math5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, mojave:      "08a8d27d961fba37b980e3ecdd87d7416429807402ddaf38d3d616808d578371"
    sha256 cellar: :any, high_sierra: "43dc2a329a12fed49066bc08d0fd788ffa346b936c7d683f8b936e86b3404b88"
    sha256 cellar: :any, sierra:      "606c4dfb580402e4cfb7ac1a5d7ccd99a7eeded41c974df618e067c1e51fd423"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "eigen"
  depends_on "ignition-cmake1"

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
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
