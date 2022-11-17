class IgnitionUtils1 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/ign-utils/releases/ignition-utils1-1.4.1.tar.bz2"
  sha256 "1a2f3be8e1c8779df911c59422331aa23cb8cc84d9f8bebfaa0656c4b8d6b199"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-utils.git", branch: "ign-utils1"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "ef7e847022760f728b5e83e8d321eabcf894c7d43aa291e20c76eb1941ee6ab1"
    sha256 cellar: :any, big_sur:  "837853e0c7387464c7ac15c8f5a2a5f7aa21debc7f2e5d87dbbe790c21e722f7"
    sha256 cellar: :any, catalina: "dd74cfaee528c3878c9aaa0865488e742bf1716bf7c15d6c2f701c6a531573b2"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "ignition-cmake2"

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
