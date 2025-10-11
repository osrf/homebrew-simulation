class GzFuelTools9 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-9.1.1.tar.bz2"
  sha256 "3189166d4b0078c0b9d98de178e5496a1cc28b88fbd1124603376181b5a053f5"
  license "Apache-2.0"
  revision 14

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "aad3b1c3bb70313e79c0b32ccf32b2f581ce95e44a910317d47a45e4d35478be"
    sha256 cellar: :any, arm64_sonoma:  "01da9a333ebe255445189e1d619841aa1f3bd2858dc0f7ffa544b84fa5ac0b65"
    sha256 cellar: :any, sonoma:        "6c693f691334110329649f0867e4e179976aa4239062caaa7cadf0064f6d2619"
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
