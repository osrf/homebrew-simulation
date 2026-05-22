class GzFuelTools11 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-11.0.0.tar.bz2"
  sha256 "4b4dee9b5a2e8cf04f1000e568187a65dd379bf54f8acf16d4e31a29240b30f0"
  license "Apache-2.0"
  revision 26

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "9ff4940a4f30a647ede6224c3028e52ec29b10f2a93186395a441352052b30f1"
    sha256 cellar: :any, arm64_sonoma:  "d7306ae24e620b1b1147f33dffe55c92013e637d0f819c49f489faccb75579ce"
    sha256 cellar: :any, sonoma:        "47bd91084cffc0658631bfb51df978d9cecd20cdfadc659b429225c8205b6cef"
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
  depends_on "protobuf"
  depends_on "spdlog"
  depends_on "tinyxml2"

  conflicts_with "gz-rotary-fuel-tools", because: "both install gz-fuel-tools"

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
