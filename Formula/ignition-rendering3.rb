class IgnitionRendering3 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/gazebosim/gz-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering3-3.6.1.tar.bz2"
  sha256 "1daba25b5cb2717d2f7ac1c65e334dcde62e5b1bebdebc804b49b2fb1dd66c03"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "ign-rendering3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 monterey: "43bd98867840cf891ef547378eb546b56bab61a74b7221cbfdf33ae0389ce406"
    sha256 big_sur:  "6dc95605d68ee5c1472b62c220e3517ddc06771fec29a70c7070d5b25488e4e4"
    sha256 catalina: "a451162b2a081f5c3a53bf40ab69840bd564dbd62f7838eab68e3cf7edec2705"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

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
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
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
      find_package(ignition-rendering3 REQUIRED COMPONENTS ogre ogre2)
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
