class IgnitionMsgs2 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://bitbucket.org/ignitionrobotics/ign-msgs"
  url "https://osrf-distributions.s3.amazonaws.com/ign-msgs/releases/ignition-msgs2-2.1.0~pre1.tar.bz2"
  version "2.1.0~pre1"
  sha256 "921d8e7ac0895b1c58e77f2db6f13510e08ca7502d0774b2e99a9efde2b30ca1"

  head "https://bitbucket.org/ignitionrobotics/ign-msgs", :branch => "default", :using => :hg

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "51b2067ffa082b224931e12c05752b2c4e8fd7b063821a789b867f63d4d5047a" => :mojave
    sha256 "bc97e6a69375820129a24388e93668c84acb40d7cd7c1542b4309018a55315a4" => :high_sierra
    sha256 "e0b9deb10f40a61eaeaad4910d4c07f150ed6851bc81d069e2ecd8c33e6ba2b0" => :sierra
  end

  depends_on "protobuf-c" => :build

  depends_on "cmake"
  depends_on "ignition-cmake1"
  depends_on "ignition-math5"
  depends_on "ignition-math6"
  depends_on "ignition-tools"
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
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-msgs2 QUIET REQUIRED)
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${IGNITION-MSGS_CXX_FLAGS}")
      include_directories(${IGNITION-MSGS_INCLUDE_DIRS})
      link_directories(${IGNITION-MSGS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-msgs2::ignition-msgs2)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-msgs2"
    cflags = `pkg-config --cflags ignition-msgs2`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-msgs2",
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
