class IgnitionRendering3 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://github.com/gazebosim/gz-rendering"
  url "https://osrf-distributions.s3.amazonaws.com/ign-rendering/releases/ignition-rendering3-3.7.2.tar.bz2"
  sha256 "531a153dc2353ee98c2fdcaf25f9550d7008f9dd93be5b53c7b95b780cb13fe1"
  license "Apache-2.0"
  revision 3

  head "https://github.com/gazebosim/gz-rendering.git", branch: "ign-rendering3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 sonoma:  "37887c604a102743e602893bdeae1fd130a0cdbb183ef68d2f2a5b40f8214816"
    sha256 ventura: "361c9bbf4b60ce05e6b1ef1b2b8caaead714bdc2d8318ffbed167267ee5c5859"
  end

  disable! date: "2025-09-01", because: "is past end-of-life date"
  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]

  depends_on "freeimage"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-plugin1"
  depends_on macos: :mojave # c++17
  depends_on "ogre1.9"
  depends_on "ogre2.1"

  def install
    rpaths = [
      rpath,
      rpath(source: lib/"ign-rendering-3/engine-plugins", target: lib),
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
    github_actions = ENV["HOMEBREW_GITHUB_ACTIONS"].present?
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
