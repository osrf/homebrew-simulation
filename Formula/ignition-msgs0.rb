class IgnitionMsgs0 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs-0.7.0.tar.bz2"
  sha256 "5e749ddad57e3e471e01cfc240a9602595dc095952cf34436c40864add08b9dc"
  revision 7

  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases"
    cellar :any
    sha256 "3f6cf639985d5c578053f1670ee022576333f2992101b824cba2b9cc8d6f4831" => :mojave
    sha256 "b9c74417be950d730952b10eddbca461919294e863cabdd26e69626ee75d9d07" => :high_sierra
    sha256 "da495426f66fddf679d84d6549c7f94698722ea1a5e30645dedbad91fe592b8f" => :sierra
    sha256 "d7c689ab872abc47fd60d500d0eb95d6ab8dec9d4d7db7dc1a401c2448f1acc6" => :el_capitan
  end

  depends_on "protobuf-c" => :build
  depends_on "cmake"
  depends_on "ignition-math3"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "ignition-tools" => :recommended

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/msgs.hh>
      int main() {
        ignition::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-msgs0 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-MSGS_LIBRARIES})
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs0"
    cflags = `pkg-config --cflags ignition-msgs0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs0",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
