class IgnitionRendering1 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering-1.0.0.tar.bz2"
  sha256 "73dc1ce94c281ddd21796ebf363e1cd03acf15709cda959926d3187462221bfe"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "cafade1cb99232ab1e187b986b0489f17121a6879aff7fde762a7417207d4689" => :mojave
    sha256 "3f065edd6db6be46c5225377f5a393e00e0877a8f1be6261aa218734aee92c05" => :high_sierra
  end

  depends_on "cmake" => :build

  depends_on "freeimage"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on :macos => :high_sierra # c++17
  depends_on "ogre1.9"
  depends_on "pkg-config"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <ignition/rendering/RenderEngine.hh>
      #include <ignition/rendering/RenderingIface.hh>
      int main(int _argc, char** _argv)
      {
        ignition::rendering::RenderEngine *engine =
            ignition::rendering::engine("ogre");
        return engine == nullptr;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(ignition-rendering1 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-rendering1::ignition-rendering1)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-rendering1"
    cflags   = `pkg-config --cflags ignition-rendering1`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering1`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
  end
end
