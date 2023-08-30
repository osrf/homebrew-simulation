class GzRendering8 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-rendering/releases/gz-rendering-8.0.0~pre1.tar.bz2"
  version "8.0.0~pre1"
  sha256 "575745d51ad51b2df23750d26b492752a581e7391f3daadb116745f25d112b01"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "4b94123e4f6215a68ce729d2348657996ea05f9e974128a0918ab6d49a3dfef8"
    sha256 monterey: "98483becf55e02e942535b54252e5253ce5a980f01caefab82e9c7aad2153f5f"
    sha256 big_sur:  "0400cadf553f92ba271f1423752b9d1e955d71148cdb932c5432e44032e33684"
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
      find_package(gz-rendering8 REQUIRED COMPONENTS ogre ogre2)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-rendering8::gz-rendering8)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-rendering8"
    cflags   = `pkg-config --cflags gz-rendering8`.split
    ldflags  = `pkg-config --libs gz-rendering8`.split
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
