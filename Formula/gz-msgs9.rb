class GzMsgs9 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-9.5.0.tar.bz2"
  sha256 "693f403fca86e9956b393a86fd46505d94e27b7b2c1d39bc631ba9c3029b91f9"
  license "Apache-2.0"
  revision 28

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "2ae4a607dbcd5393869b8d7af1e980b12130bb5d3d7ac06cdf04663b5ec8158f"
    sha256 cellar: :any, monterey: "112a832b9040842900a62446738de5c161bb6464ec85588f87286ec483efd97e"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <gz/msgs.hh>
      int main() {
        gz::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(gz-msgs9 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-msgs9::gz-msgs9)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-msgs9"
    # cflags = `pkg-config --cflags gz-msgs9`.split
    # ldflags = `pkg-config --libs gz-msgs9`.split
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                *ldflags,
    #                "-o", "test"
    # system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
