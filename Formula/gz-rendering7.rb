class GzRendering7 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-rendering/releases/gz-rendering-7.1.0.tar.bz2"
  sha256 "e4b7f899b6232d99594a12bfb0b93409d0e94ecbf9643ef2ee5ce946200b619d"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "gz-rendering7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 monterey: "9f1db00a3a64926a3cd2785acb7cdb0f2549916475e544ccd5ad0dc0c2bbd036"
    sha256 big_sur:  "c63ff0ebbe8cc34ca7e272490ff3b4453f405ad8816463ebefc80f5a47acfd12"
    sha256 catalina: "b0d28262652d3bafc787a0d2d7719917e28a1479d8458c5bbb61763a99ec7cf0"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "freeimage"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-math7"
  depends_on "gz-plugin2"
  depends_on "gz-utils2"
  depends_on macos: :mojave # c++17
  depends_on "ogre1.9"
  depends_on "ogre2.3"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    github_actions = ENV["HOMEBREW_GITHUB_ACTIONS"].present?
    (testpath/"test.cpp").write <<-EOS
      #include <gz/rendering/RenderEngine.hh>
      #include <gz/rendering/RenderingIface.hh>
      int main(int _argc, char** _argv)
      {
        gz::rendering::RenderEngine *engine =
            gz::rendering::engine("ogre");
        return engine == nullptr;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
      find_package(gz-rendering7 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-rendering7::gz-rendering7)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-rendering7"
    cflags   = `pkg-config --cflags gz-rendering7`.split
    ldflags  = `pkg-config --libs gz-rendering7`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test" unless github_actions
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake" unless github_actions
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
