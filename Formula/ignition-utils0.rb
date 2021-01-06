class IgnitionUtils0 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/ignitionrobotics/ign-utils"
  url "https://github.com/ignitionrobotics/ign-utils/archive/20527970a7795661d8ca7b15f8197e4457595ce5.tar.gz"
  version "0.1.0~pre1"
  sha256 "fcb84b71063b7a2a9a0b53e31aa57101e1dc4005e2d38487e046bdec2849ec46"
  license "Apache-2.0"

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "pkg-config"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/utils/ImplPtr.hh>
      class SomeClassPrivate
      {
      };
      class SomeClass
      {
        private: ignition::utils::ImplPtr<SomeClassPrivate> dataPtr;
      };
      int main() {
        SomeClass object;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-utils0 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-UTILS_LIBRARIES})
    EOS
    system "pkg-config", "ignition-utils0"
    system ENV.cc, "test.cpp",
                   "--std=c++17",
                   "-I#{include}/ignition/utils0",
                   "-L#{lib}",
                   "-lignition-utils0",
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
