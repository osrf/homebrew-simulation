class IgnitionFuelTools6 < Formula
  desc "Tools for using Fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://github.com/ignitionrobotics/ign-fuel-tools/archive/eea5e1d3c8ac1e18eb90e6a82fb7bdb4f566c495.tar.gz"
  version "5.999.999~0~20210111~eea5e1"
  sha256 "b868e39916dc21fc86e80c18d5004c0e7b26d7ac0a4af99eb8c77e72ea8bf5f1"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-fuel-tools", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any
    sha256 "b97407a88219f524c20f8caed4bafe44570db61fc2acd00302e10e2f6392f5bd" => :mojave
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-msgs7"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/fuel_tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel_tools6 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL_TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL_TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-fuel_tools6::ignition-fuel_tools6)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel_tools6"
    cflags = `pkg-config --cflags ignition-fuel_tools6`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel_tools6",
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
