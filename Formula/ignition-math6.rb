class IgnitionMath6 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-math/releases/ignition-math-6.16.0.tar.bz2"
  sha256 "831a153253044bcb505dc9cf50b7f1e8c4ccd9213dd5bdb1d6d13719f775c991"
  license "Apache-2.0"
  revision 2

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "e1ccb2baa14790a842c994c439af64a3cfe56bce070fb268743a1b9c58c53573"
    sha256 cellar: :any, arm64_sonoma:  "ae9bf3c1dccb2570c6e5717db51a4b902f3f971a7aff774d61bacb5dcc431a5b"
    sha256 cellar: :any, sonoma:        "a8ef83982466c31519add1d4fe95f0966ceada9318beb145e9448ca961a2c315"
  end

  # head "https://github.com/gazebosim/gz-math.git", branch: "ign-math6"

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "eigen"
  depends_on "ignition-cmake2"
  depends_on "python@3.11"
  depends_on "ruby"

  def install
    cmake_args = std_cmake_args
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
