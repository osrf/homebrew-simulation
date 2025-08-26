class GzFuelTools9 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-9.1.1.tar.bz2"
  sha256 "3189166d4b0078c0b9d98de178e5496a1cc28b88fbd1124603376181b5a053f5"
  license "Apache-2.0"
  revision 12

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sonoma: "29aa7dd8ba2e8daa0968dbe3a098d81a8f485957c64617602d2def1e9c5af1e9"
    sha256 cellar: :any, sonoma:       "d7466ddaeab68543f444ed9893cb4e5e45f6f37de0c825b67f5bb5bbe5194691"
    sha256 cellar: :any, ventura:      "3f1cdc01e41799ac3d8de6114711257c7ad5cdf22380a9f9890c923935eae4ed"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-msgs10"
  depends_on "gz-utils2"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on macos: :high_sierra # c++17
  depends_on "pkgconf"
  depends_on "protobuf"
  depends_on "tinyxml2"

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
      #include <gz/fuel_tools.hh>
      int main() {
        gz::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-fuel_tools9 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-fuel_tools9::gz-fuel_tools9)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-fuel_tools9"
    cflags = `pkg-config --cflags gz-fuel_tools9`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-fuel_tools9",
                   "-lc++",
                   "-o", "test"
    system "./test"
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
