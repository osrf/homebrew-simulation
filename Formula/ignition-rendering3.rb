class IgnitionRendering3 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering3-3.4.0.tar.bz2"
  sha256 "a30ddc8168e9b95e47d4c52cfcedf5d016889296fde6e3eb5710384ac32c0f82"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "4b46cc0f564f19d4b57a693486ee2ed53b2a09ff4d3100fecb6c50f5a2a56c95"
    sha256 mojave:   "eb59eb9b7467cc514acbd1d0fb9a89a32c3ef6e1e098c11735f444894e4885b8"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "freeimage"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on macos: :mojave # c++17
  depends_on "ogre1.9"
  depends_on "ogre2.1"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    azure = ENV["HOMEBREW_AZURE_PIPELINES"].present?
    github_actions = ENV["HOMEBREW_GITHUB_ACTIONS"].present?
    travis = ENV["HOMEBREW_TRAVIS_CI"].present?
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
      find_package(ignition-rendering3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-rendering3::ignition-rendering3)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-rendering3"
    cflags   = `pkg-config --cflags ignition-rendering3`.split
    ldflags  = `pkg-config --libs ignition-rendering3`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test" if !(azure || github_actions) && !travis
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake" if !(azure || github_actions) && !travis
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
