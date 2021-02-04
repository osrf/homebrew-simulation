class IgnitionPlugin1 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/ign-plugin/releases/ignition-plugin-1.1.0.tar.bz2"
  sha256 "72e6a9af35507b8f49e22205e44110419fc9170f7fc8d7e491587db2287041ae"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, mojave:      "91c8bc679f8c04d6ece956d40402652ada5cf787a7ad5e40955518fad6e91f3b"
    sha256 cellar: :any, high_sierra: "db96234b2a9b44b289d274d9f916f260f363b03edf67327dff85e46539961fb8"
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
