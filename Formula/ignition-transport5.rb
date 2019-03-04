class IgnitionTransport5 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport5-5.0.0.tar.bz2"
  sha256 "9704f4ad16b2caf1d24e51fca0994aff23a43f565f03c66b2b6670c98e1ea080"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "457023ef69511b76512c661fa2f73c04784b101300d10b5540c477728ae88be0" => :mojave
    sha256 "3ed6d6428dfbff884c9d265af46b755efb4d3444f5a1d3d1bee3c7b2545e5b51" => :high_sierra
    sha256 "0494a46b981d89db571a06ef663c01c2bd046885135742ec1308693e541b2d0c" => :sierra
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake1"
  depends_on "ignition-msgs2"
  depends_on "ignition-tools"
  depends_on "ossp-uuid"
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "zeromq"

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
      find_package(ignition-transport5 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport5::ignition-transport5)
    EOS
    system "pkg-config", "ignition-transport5"
    cflags = `pkg-config --cflags ignition-transport5`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport5",
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
