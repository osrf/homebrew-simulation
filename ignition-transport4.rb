class IgnitionTransport4 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-transport/releases/ignition-transport4-4.0.0.tar.bz2"
  sha256 "b0d8d3d4b0d4fbb06ed293955f5dfe2f840fe510daec867422676b41fc3824b4"

  head "https://bitbucket.org/ignitionrobotics/ign-transport", :branch => "ign-transport4", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/ign-transport/releases"
    cellar :any
    sha256 "31fd7e8e66a8d21873c666b9ff8511811c6605ee3a032b11f222372d0581fdcf" => :high_sierra
    sha256 "d3fa1d9928fbdefec5a5431c6655ba222b8f9b6bfacff3f33f111e5d80c6357b" => :sierra
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
