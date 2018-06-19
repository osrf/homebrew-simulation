class IgnitionMsgs3 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://bitbucket.org/ignitionrobotics/ign-msgs/get/c711bd9a656ecd85d199f4b7fe861b555408559f.tar.gz"
  version "2.999.999~20180618~c711bd9"
  sha256 "63d12f84881b30dc0d7e60ec6217a73234ad5feee5540681ed192a81161b284b"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-msgs/releases"
    sha256 "460e43d056118b26cf656c1c9dddd2226ab196934c094c16fe7f6f33cdeddf63" => :high_sierra
    sha256 "fbde98a15e2256b4c3cd3897f24a3372984b5793295422b3ffe811e15c041df2" => :sierra
    sha256 "873064464e6673bb15df5bde47e49da7086166963889223bf686623131204d86" => :el_capitan
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build

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
