class GzFuelTools11 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-11.0.0.tar.bz2"
  sha256 "4b4dee9b5a2e8cf04f1000e568187a65dd379bf54f8acf16d4e31a29240b30f0"
  license "Apache-2.0"
  revision 16

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "f41b83c24daa16698e953bae0bd4ddeca48476c1224658b59c1d15f52b7ef1f1"
    sha256 cellar: :any, arm64_sonoma:  "6b13f0ebd5c12eee8707f44b76653a1d8a690d1006a279f70adb32c8b73c5e07"
    sha256 cellar: :any, sonoma:        "24daea83697358b6c11f7a3e8a8cf6beb14e22cba80a78085ab45c54a6c27ff1"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "fmt"
  depends_on "gz-cmake5"
  depends_on "gz-common7"
  depends_on "gz-math9"
  depends_on "gz-msgs12"
  depends_on "gz-utils4"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "pkgconf"
  depends_on "protobuf@33"
  depends_on "spdlog"
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
    ENV.append_path "PKG_CONFIG_PATH", Formula["protobuf@33"].opt_lib/"pkgconfig"
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
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["protobuf@33"].opt_prefix
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
