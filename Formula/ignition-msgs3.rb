class IgnitionMsgs3 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs3-3.0.0.tar.bz2"
  sha256 "24971b26aa065944fd06210476c3101f0f98f6a93c67ca05decb4cedd418f1db"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "1e5d26a7ae309855c77a4f732460530f155a4e478f1fb11dd745d279cdd07740" => :mojave
    sha256 "661b3da4c1cbed34c25ae2eb35d244d09a7a3cb40b79518e3a9d5a9f6d51340c" => :high_sierra
  end

  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on :macos => :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"

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
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-msgs3 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs3::ignition-msgs3)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs3"
    cflags = `pkg-config --cflags ignition-msgs3`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs3",
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
