class GzFuelTools10 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-10.1.0.tar.bz2"
  sha256 "37ae351be9a9b281d078e36068422dd096f59f46c72c4ef490800dfeb7653e1d"
  license "Apache-2.0"
  revision 20

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "3004167767186bb99ed0ff281dab14877442e7aad4639897e8deaf788fb615f7"
    sha256 cellar: :any, arm64_sonoma:  "3ebbda15fa2c46daa20df01f306dcfb2a0cd450ab0553f9b7358d49b64e7aa96"
    sha256 cellar: :any, sonoma:        "ab839924fa7dfcc3d0de7e324318910811c2e7c9fe0ad6f79fb80952f0379097"
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
