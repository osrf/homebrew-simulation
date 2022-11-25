class GzFuelTools8 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-8.0.1.tar.bz2"
  sha256 "4cfd0c4f45953c3ae6ffc66654be5b4e73a32f27d8b50390cad69cd821ba928e"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "7baa1f45d7a838fc1447cc303370492508f502a7e4bed8e56a826bbfe96d459d"
    sha256 cellar: :any, big_sur:  "dee8b8f3ced2e4c8637624fdb60b0c3f3c94cd82aac50a70bd1a230339ee6427"
    sha256 cellar: :any, catalina: "0bc926683a698394d6177e9d70886611aac4f05c1c501b665f00780fe0a72a64"
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
