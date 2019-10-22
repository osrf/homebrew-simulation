class IgnitionRendering3 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering3-3.0.0~pre1.tar.bz2"
  version "3.0.0~pre1"
  sha256 "31a569ca86c7417b01ab3dca378710d53dac0c91544307aac2e99baaf7825017"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "0d34aa5b2b59752028ba6aecd714da42d6f9d98cd182c90de024f083d4c814ed" => :mojave
    sha256 "2a906dfff3e4dbe051974b6861e128d0f244d3ac9fbde9ce82caeff99db5b370" => :high_sierra
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "freeimage"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on :macos => :high_sierra # c++17
  depends_on "ogre1.9"
  depends_on "ogre2.1"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    azure = !ENV["HOMEBREW_AZURE_PIPELINES"].nil?
    travis = !ENV["HOMEBREW_TRAVIS_CI"].nil?
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
    cflags   = `pkg-config --cflags ignition-rendering3`.split(" ")
    ldflags  = `pkg-config --libs ignition-rendering3`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test" unless azure || travis
    # test building with cmake
    mkdir "build" do
      ENV.delete("MACOSX_DEPLOYMENT_TARGET")
      ENV.delete("SDKROOT")
      system "cmake", ".."
      system "make"
      system "./test_cmake" unless azure || travis
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
