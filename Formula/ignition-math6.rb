class IgnitionMath6 < Formula
  desc "Math API for robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-math/releases/ignition-math6-6.10.0.tar.bz2"
  sha256 "8de0f92a5a2bbce84695ba75ab798c22d32da54be454736af6bbcb6eed404902"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, big_sur:  "c362eab95b7b352adf03a55ba668ed2c02935cc6b78634213c6a069178c12c16"
    sha256 cellar: :any, catalina: "c29fa4e877062bf5e4c6a6b27b429783239853bbe35ada9776160fe9000c181b"
  end

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "pybind11" => :build
  depends_on "eigen"
  depends_on "ignition-cmake2"
  depends_on "ruby"

  # needed to fix build
  # see https://github.com/ignitionrobotics/ign-math/pull/402
  patch :DATA

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"
    system "cmake", ".", *cmake_args
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
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 1f8ed5f..6403a71 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -71,13 +71,12 @@ endif()
 
 ########################################
 # Python bindings
-include(IgnPython)
-find_package(PythonLibs QUIET)
-if (NOT PYTHONLIBS_FOUND)
+find_package(Python3 COMPONENTS Interpreter Development)
+if (NOT Python3_FOUND)
   IGN_BUILD_WARNING("Python is missing: Python interfaces are disabled.")
   message (STATUS "Searching for Python - not found.")
 else()
-  message (STATUS "Searching for Python - found version ${PYTHONLIBS_VERSION_STRING}.")
+  message (STATUS "Searching for Python - found version ${Python3_VERSION}.")
 
   set(PYBIND11_PYTHON_VERSION 3)
   find_package(pybind11 2.2 QUIET)
