class IgnitionTransport4 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases/ignition-transport4-4.0.0.tar.bz2"
  sha256 "b0d8d3d4b0d4fbb06ed293955f5dfe2f840fe510daec867422676b41fc3824b4"
  revision 3

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport4", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/ign-transport/releases"
    cellar :any
    sha256 "cb0d3f9f60a888f822d6edd85d60dac72e6a6ee8cd37402679c031a104e477d3" => :mojave
    sha256 "d6f198e35bfada6540a67de56fedaf953b9de058799b4263ee5b433953258c9a" => :high_sierra
    sha256 "e46cdb2bc01143fb9364af56d715b627470669dacdeb12fa77afb54c6bd1b236" => :sierra
    sha256 "323532012a4dc16edf06fc96a9620196cdc574e4f5534fe69d712eb325502195" => :el_capitan
  end

  depends_on "doxygen" => [:build, :optional]

  depends_on "protobuf-c" => :build
  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake0"
  depends_on "ignition-msgs1"
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
      find_package(ignition-transport4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport4::ignition-transport4)
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
