class IgnitionTransport4 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-transport/get/4fbebfb97acb.tar.gz"
  version "3.9.9~20171212~4fbebfb97acb"
  sha256 "1c20423edc743b365e3246f042e5d395268bca1a4a3464d25f19c7d734e719eb"

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport4", :using => :hg

  # bottle do
  #   root_url "http://gazebosim.org/distributions/ign-transport/releases"
  #   cellar :any
  #   sha256 "3b106604af2e8ccfb665ee0d3e677b3a075ec380ee7d818b33892c2ba965bbc3" => :high_sierra
  #   sha256 "c7a355b6aa97db3d8dae30362db6747173cc49977569e10442b827805cfc7649" => :sierra
  #   sha256 "f142839194381a6da9ca6dbe1a3c7c83238dc93245b12924fde9fea791e1b829" => :el_capitan
  # end

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
    (testpath/"test.cpp").write <<-EOS.undent
      #include <iostream>
      #include <ignition/transport.hh>
      int main() {
        ignition::transport::Node node;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS.undent
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
