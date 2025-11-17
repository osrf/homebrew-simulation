class GzFuelTools11 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-11.0.0.tar.bz2"
  sha256 "4b4dee9b5a2e8cf04f1000e568187a65dd379bf54f8acf16d4e31a29240b30f0"
  license "Apache-2.0"
  revision 8

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "0e671f805ba9ad22832a1ab773540303922cd395b2eca641453416a43b722669"
    sha256 cellar: :any, arm64_sonoma:  "d7df0c38cedd8c31859844279c0b81e5ac6ebbc7600a02c3a3645ab8cac2177c"
    sha256 cellar: :any, sonoma:        "eaa7c7d09cf0cca31ab8ba9b5c4f7da4f0db51ad23dbf98e92fd7d47f264d686"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-utils4"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
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
      find_package(gz-fuel_tools QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-fuel_tools::gz-fuel_tools)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-fuel_tools"
    cflags = `pkg-config --cflags gz-fuel_tools`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-fuel_tools",
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
