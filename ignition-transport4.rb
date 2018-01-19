class IgnitionTransport4 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport4-4.0.0~pre1.tar.bz2"
  version "4.0.0~pre1"
  sha256 "b1b83433a763d6ff1a5cbd2d19cda7573c400245215061b409e039b8bd96b764"

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport4", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "c752172acbeb46d4d52d28f9c5782ee6c2019dc2b225d92ae6d7bc874a9047f6" => :high_sierra
    sha256 "c459c177f25ef77a11f185f0638d35d99092a892ef82e6228a3e5dd88722e982" => :sierra
    sha256 "ff168245ed7e5d892c2b01bb379fb9cd7569ed709bb757a4d7da9e0a8ef0d12d" => :el_capitan
  end

  depends_on "cmake" => :run
  depends_on "doxygen" => [:build, :optional]
  depends_on "pkg-config" => :run

  depends_on "ignition-cmake0"
  depends_on "ignition-msgs1"
  depends_on "ignition-tools"
  depends_on "protobuf"
  depends_on "protobuf-c" => :build
  depends_on "ossp-uuid"
  depends_on "zeromq"
  depends_on "cppzmq"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>
      #include <ignition/transport.hh>
      int main() {
        ignition::transport::Node node;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-transport4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${ignition-transport4_LIBRARIES})
    EOS
    system "pkg-config", "ignition-transport4"
    cflags = `pkg-config --cflags ignition-transport4`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport4",
                   "-lc++",
                   "-o", "test"
    system "./test"
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
