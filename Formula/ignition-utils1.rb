class IgnitionUtils1 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/ignitionrobotics/ign-utils"
  url "https://osrf-distributions.s3.amazonaws.com/ign-utils/releases/ignition-utils1-1.0.0.tar.bz2"
  sha256 "e916dc70b96d8131d37866f0cc583f87bd4c168fb7e63ea532ded96547dc7a2c"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "5460f3243bd28c203fbd50db14892ba6bd566949774dd0f8c851497494f1ff3f"
    sha256 cellar: :any, mojave:   "6e7bc53dfed9288be12f2cbe53edd0acffb8090c00a86989cc13ee02320bbb01"
  end

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
      find_package(ignition-utils1 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-UTILS_LIBRARIES})
    EOS
    system "pkg-config", "ignition-utils1"
    cflags = `pkg-config --cflags ignition-utils1`.split
    ldflags = `pkg-config --libs ignition-utils1`.split
    system ENV.cxx, "test.cpp",
                    *cflags,
                    *ldflags,
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
