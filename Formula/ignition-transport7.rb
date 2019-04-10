class IgnitionTransport6 < Formula
  desc "Transport middleware for robotics"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-transport/commits/57d82e80aa9e84f83c5e2d4f3d7a91aecc488af5.tar.bz2"
  sha256 "6b3781ee6f9f412f5068ce01fa92cf70b36d4ee3b63aadd7bea5453919c52549"
  revision 1

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "2093d9f4a4380e612a063a53dfd14de514868a86448cc055cf682637cd296391" => :mojave
    sha256 "43167574991c35c9692b69becece4c4f1f162c573a1ee6e54abb59b0dda3bb5c" => :high_sierra
  end

  depends_on "doxygen" => [:build, :optional]
  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "cppzmq"
  depends_on "ignition-cmake2"
  depends_on "ignition-msgs4"
  depends_on "ignition-tools"
  depends_on :macos => :high_sierra # c++17
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
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(ignition-transport6 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-transport6::ignition-transport6)
    EOS
    system "pkg-config", "ignition-transport6"
    cflags = `pkg-config --cflags ignition-transport6`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-transport6",
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
