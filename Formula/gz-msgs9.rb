class GzMsgs9 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-9.5.0.tar.bz2"
  sha256 "693f403fca86e9956b393a86fd46505d94e27b7b2c1d39bc631ba9c3029b91f9"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "94490fb37ef3470ba7787d93299900506c5435848ad7a722ebcc67db71bf3177"
    sha256 cellar: :any, monterey: "8fcd6df5b03941ae897d9113a83eddc4b7c9b1d9f4ef98307c3b4efa84c00006"
    sha256 cellar: :any, big_sur:  "fa9290aa675c040d3ef08f4bc3b1d2a035cb83673a6be97f9d5969461c27a9fb"
  end

  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-tools2"
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
