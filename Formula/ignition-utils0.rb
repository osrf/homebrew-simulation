class IgnitionUtils0 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/ignitionrobotics/ign-utils"
  url "https://github.com/ignitionrobotics/ign-utils/archive/20a2b6fc0030cd3abbac36d476da8e36d6794404.tar.gz"
  version "0.1.0~pre0~0~20201223~20a2b6f"
  sha256 "fa5584d13116ef2b00a1776a8acacdc27f1d5755e416763bb836bb0490558bfd"
  license "Apache-2.0"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "ignition-cmake2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
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
        private: ignition::utils::ImplPtr<SomeClassPrivate> dataPtr =
            ignition::utils::MakeImpl<SomeClassPrivate>();
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
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
