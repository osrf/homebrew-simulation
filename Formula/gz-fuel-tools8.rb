class GzFuelTools8 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-fuel-tools/releases/gz-fuel_tools-8.0.2.tar.bz2"
  sha256 "63e482b063bab7169de81630f644f844f0f2c96e911c331dcb9ea3a82129a363"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-fuel-tools.git", branch: "gz-fuel-tools8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "63f83c44b42cd9cededddfd026a062bc13cf16a7312d9362df2c384a5fc9ab76"
    sha256 cellar: :any, big_sur:  "5f840a9886d668057867d05f02e8c2d711ec440d9a953f05d10f2efba9616373"
    sha256 cellar: :any, catalina: "6dffb3e830478920f2d565cdd5481d36ffa79601e83656c0966837a341cf9a9e"
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
