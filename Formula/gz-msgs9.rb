class GzMsgs9 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-9.4.0.tar.bz2"
  sha256 "6690ea3ab938afa4980373008dcc4119da43e4c51763a46948f6fd549144e993"
  license "Apache-2.0"
  revision 6

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "8eab28c1eaadb266ed5494549c642883ec5cce62b2c69fda8193c515150a25fe"
    sha256 cellar: :any, big_sur:  "9373239a837f13aed4ddaaec421febee126280f3901aba3af07698164d6072d5"
  end

  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-tools2"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "tinyxml2"

  patch do
    # Fix for compatibility with protobuf 23.2
    url "https://github.com/gazebosim/gz-msgs/commit/87a9235cd14d65b26428d6905c83a6269d82d741.patch?full_index=1"
    sha256 "a3493afdd6a0e606459ee2c8d0a101775cdbb403d38056d626d2801191a29e7d"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
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
