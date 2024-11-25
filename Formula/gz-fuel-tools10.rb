class GzFuelTools10 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-10.0.0.tar.bz2"
  sha256 "dce4fb51a6af8d15d3ebdd98ecff4baf47c02ffb4d6aed48b284a7ce9188778e"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "85ee3641a9a07556eb6acf7135231445e12640217c3308a7cf397d6d9ca5d997"
    sha256 cellar: :any, ventura: "ff4ba1ba9ddf358d7a9f76fe83c22026f4963c81c864d6cbb249be926e9b6a81"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake4"
  depends_on "gz-common6"
  depends_on "gz-math8"
  depends_on "gz-msgs11"
  depends_on "gz-utils3"
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
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-fuel_tools10 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-fuel_tools10::gz-fuel_tools10)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-fuel_tools10"
    cflags = `pkg-config --cflags gz-fuel_tools10`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-fuel_tools10",
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
