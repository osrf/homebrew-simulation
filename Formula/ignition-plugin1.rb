class IgnitionPlugin1 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/ign-plugin/releases/ignition-plugin-1.2.0.tar.bz2"
  sha256 "0f5e1fe9b4807dbf7e0d4924e5f76bdb1d604ad3c6912abb3e5e9bcf80531a4a"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, catalina: "6a8e98aa6998e034b73ec621bdb6a9f6a08174729496d60744ce4ac415dd993f"
    sha256 cellar: :any, mojave:   "04b76e65ba4e0e33cce431a7442cf531dfa7026ff9368a3a4b07f5e14359528f"
  end

  depends_on "cmake"
  depends_on "ignition-cmake2"
  depends_on "ignition-tools"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/plugin/Loader.hh>
      int main() {
        ignition::plugin::Loader loader;
        return loader.InterfacesImplemented().size();
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(ignition-plugin1 QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-PLUGIN_LIBRARIES})
    EOS
    system "pkg-config", "ignition-plugin1-loader"
    cflags = `pkg-config --cflags ignition-plugin1-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-plugin1-loader",
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
