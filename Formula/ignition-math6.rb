class IgnitionMath6 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-math/releases/ignition-math6-6.15.1.tar.bz2"
  sha256 "a9e96a4e28d7d92d4d054cdae7cef28f1d8397b72433398bfc68855956531170"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-math.git", branch: "ign-math6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:   "9c765e4736151e3b9f7bbd0e81939b9405329ee1f227c99b94b6717e96e1f8d0"
    sha256 cellar: :any, ventura:  "f04b2a2952cbc588a80d3b809c851410f89cb39ad24134be92662d4751bf3f0a"
    sha256 cellar: :any, monterey: "a34fdd037896e72df9f0c4c20dc2dc4d953ffad9977ab14b7f6b1667bad1493e"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "eigen"
  depends_on "ignition-cmake2"
  depends_on "python@3.11"
  depends_on "ruby"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
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
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
