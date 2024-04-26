class GzFuelTools8 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-8.1.0.tar.bz2"
  sha256 "18a25e2bc31e61539c890bdd377068b5192646a6647267e76d9b0bb0d0349545"
  license "Apache-2.0"
  revision 24

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "253d9774c2d9b0f56a738a8ca12691b00f849a214b1afd343eb715ec33c4fd85"
    sha256 cellar: :any, monterey: "01c36a24df0062c13d3f3bf94668a31bfd50f77ae45260bcf4dda5a1880934c5"
  end

  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-msgs9"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
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
      #include <gz/fuel_tools.hh>
      int main() {
        gz::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(gz-fuel_tools8 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-fuel_tools8::gz-fuel_tools8)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-fuel_tools8"
    cflags = `pkg-config --cflags gz-fuel_tools8`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-fuel_tools8",
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
