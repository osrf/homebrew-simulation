class IgnitionRendering3 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering3-3.1.0.tar.bz2"
  sha256 "eb3c567455a1a6a999ace04544efaeda788d8d6f411a23a8e47dba71a736e553"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "6576ac1c425ccd102ab8f5b1e4b91eea0f645a05e726a820495bdbb071e2350d" => :mojave
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
      system "cmake", ".."
      system "make"
      system "./test_cmake" unless azure || travis
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
