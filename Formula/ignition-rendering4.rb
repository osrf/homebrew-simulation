class IgnitionRendering4 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering4-4.0.0.tar.bz2"
  sha256 "97d4936034ce682ae4a49a658a052f1d2c9e32c017103cd844836f7b5ba32237"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "0a24f14be8bc46df19e3030c0a11377ab47aa577936967ca7f4ac67899b1f31b" => :mojave
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
      find_package(ignition-rendering4 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ignition-rendering4::ignition-rendering4)
    EOS
    # test building with pkg-config
    system "pkg-config", "ignition-rendering4"
    cflags   = `pkg-config --cflags ignition-rendering4`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering4`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test" unless azure || github_actions || travis
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake" unless azure || github_actions || travis
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
