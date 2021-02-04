class IgnitionPlugin0 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/ign-plugin/releases/ignition-plugin0-0.2.0~pre1.tar.bz2"
  version "0.2.0~pre1"
  sha256 "9ba562b503c98914ae8ca392db833c6a3f0fec5cc7c56e1229740dd0d0122db9"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/ign-plugin/releases"
    sha256 cellar: :any, mojave:      "8bab9824aa1e5a1bd6e11e9b9408fe6ff911cb33db3e201936d3f0e27e883398"
    sha256 cellar: :any, high_sierra: "4c9f8cb01899c3871237e36c0394f513d3c5209104d821b87cbe1170860dc4a4"
    sha256 cellar: :any, sierra:      "1488ce3c65c2131d8e46aae8cccbefa0fe6836a8b164c3db9cd126dfd091fa13"
    sha256 cellar: :any, el_capitan:  "813f6a21a9f722cb1ca605e4d1703e77ea753ae2c9e43ed0c3393b69ec902719"
  end

  depends_on "cmake"
  depends_on "ignition-cmake1"
  depends_on "pkg-config"

  def install
    system "cmake", ".", *std_cmake_args
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
      find_package(ignition-plugin0 QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${IGNITION-PLUGIN_LIBRARIES})
    EOS
    system "pkg-config", "ignition-plugin0-loader"
    cflags = `pkg-config --cflags ignition-plugin0-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lignition-plugin0-loader",
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
