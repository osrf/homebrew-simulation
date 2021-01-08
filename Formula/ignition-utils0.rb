class IgnitionUtils0 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/ignitionrobotics/ign-utils"
  url "https://github.com/ignitionrobotics/ign-utils/archive/922bb53992fd275817a3c0b093bc8ed1cb4743af.tar.gz"
  version "0.1.0~pre0~0~20210107~922bb53"
  sha256 "feaee24774ad06e9a735ad3bc5341c75bbc33a1eafdf528a6a1acce48eba2488"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "12378ce9c4da350fc3b55be0193dfc3f54ffa4b3717f652247b50f5ee2004836" => :mojave
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
      find_package(ignition-utils0 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-UTILS_LIBRARIES})
    EOS
    system "pkg-config", "ignition-utils0"
    cflags = `pkg-config --cflags ignition-utils0`.split
    ldflags = `pkg-config --libs ignition-utils0`.split
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
