class IgnitionMath6 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-math/releases/ignition-math6-6.13.0.tar.bz2"
  sha256 "4d412a53644ecb984a0f64ca5df6e7043514673a406cd6228173278ce4eaf924"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-math.git", branch: "ign-math6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "454848e5baaa89e55aeed4099745cfd7f8f664f37bc1a60c794d131ef7e989fc"
    sha256 cellar: :any, big_sur:  "f0a2c4558bbba2e7d5decf2ca2cdece0126638c50074d29b4f46ae302b5bf0ee"
    sha256 cellar: :any, catalina: "e1b5423ca61a04d4275c60a22f466175bb077addb8c9aef74656b74f46b56997"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "eigen"
  depends_on "ignition-cmake2"
  depends_on "python"
  depends_on "ruby"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use build folder
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
