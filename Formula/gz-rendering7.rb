class GzRendering7 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-rendering/releases/gz-rendering-7.4.2.tar.bz2"
  sha256 "81101ddb26c630dd0292c34a83d7736596d8ee1ac5d7b8ec4980f485de8ba87d"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "gz-rendering7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "553fc8ea77688fd97354525418814a0d0b3a0a29b85de011987e2b29417cb865"
    sha256 monterey: "ea61caed7c72f4bce5d559f888f7baa3c368b56da165d9c08cdc836ea4a247e1"
    sha256 big_sur:  "39844d2004e2e338d77556ad696c47de3ac39800132845c5ba39a3e57adae9d3"
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

  patch do
    # use CMAKE_INSTALL_RPATH values in ogre2 library
    url "https://github.com/gazebosim/gz-rendering/commit/65ffacb49e5c5477e2ee5241bb45fdfd2273a5ae.patch?full_index=1"
    sha256 "ed13b1d5e74d3a4e66c33a52149eb6be581b5f97014e2745d9e18ad216913fd8"
  end

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"gz-rendering-7/engine-plugins", target: lib),
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
      p = lib/"gz-rendering-7/engine-plugins/libgz-rendering-#{engine}.dylib"
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
      find_package(gz-rendering7 REQUIRED COMPONENTS ogre ogre2)
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
