class GzRendering8 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-rendering/releases/gz-rendering-8.0.0~pre3.tar.bz2"
  version "8.0.0-pre3"
  sha256 "2202d17ee7c6d48b029681b3f198dc68f87e07bb4bd6ae2945f9e6d520e510d9"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "gz-rendering8"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "fb88f729a98a20ab22d3c1abf89163ef6db2ff06e4930656a17b9f3db7f4cb66"
    sha256 monterey: "a4e01cb771e89b5415158f5b23c6b3fde152e4cd983a56908b53e08b158c2f2e"
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
    rpaths = [
      rpath,
      rpath(source: lib/"gz-rendering-8/engine-plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test plugins in subfolders
    ["ogre", "ogre2"].each do |engine|
      p = lib/"gz-rendering-8/engine-plugins/libgz-rendering-#{engine}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args: args)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    end
    # build against API
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
