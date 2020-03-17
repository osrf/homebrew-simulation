class IgnitionFuelTools0 < Formula
  desc "Tools for using fuel API to download robot models"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-fuel-tools/get/4bf08a71cb16298c130b6f0f060bd42f5fcf99ae.tar.gz"
  version "0.1.3~20180108~4bf08a71cb"
  sha256 "68f375a2cf2bb6adfa4ecd801b822f0d475af5df5efa41182374adc02f769da1"

  depends_on "cmake"
  depends_on "ignition-cmake0"
  depends_on "ignition-common1"
  depends_on "jsoncpp"
  depends_on "libyaml"
  depends_on "libzip"
  depends_on "pkg-config"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/fuel-tools.hh>
      int main() {
        ignition::fuel_tools::ServerConfig srv;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(ignition-fuel-tools0 QUIET REQUIRED)
      include_directories(${IGNITION-FUEL-TOOLS_INCLUDE_DIRS})
      link_directories(${IGNITION-FUEL-TOOLS_LIBRARY_DIRS})
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-FUEL-TOOLS_LIBRARIES})
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-fuel-tools0"
    cflags = `pkg-config --cflags ignition-fuel-tools0`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-fuel-tools0",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
