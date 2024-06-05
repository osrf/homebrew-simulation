class GzFuelTools9 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-9.0.3.tar.bz2"
  sha256 "242687de20af956485372a43f47a0fd093ecb17ee62d268211c6223e204f94cf"
  license "Apache-2.0"
  revision 7

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "eb75dd8aecf7b975161fb5fc1eab91b246929287f89a6730f214b0deb24dc1b2"
    sha256 cellar: :any, monterey: "49dc61cf262b4d526f17b8e89076060b5cb703e30c9f11b8cb6e7070237faf88"
  end

  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-msgs10"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
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
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
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
