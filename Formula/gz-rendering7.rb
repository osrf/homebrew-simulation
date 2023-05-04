class GzRendering7 < Formula
  desc "Rendering library for robotics applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-rendering/releases/gz-rendering-7.3.1.tar.bz2"
  sha256 "1fe69821ef29bcd6929fbb61262b8dc108add1bae31abcb80d5b13f7a71a1fea"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-rendering.git", branch: "gz-rendering7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 monterey: "f54621e3b91d7972de54c9c08f4225cb03abb5d49c057684d006d802c29c73b7"
    sha256 big_sur:  "e2b3ac69538080fa684223f723ccfc38e097ee97a19b46494e4d1850e9378c5f"
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
    # Fix for pkg-config
    # Remove with next release
    url "https://github.com/gazebosim/gz-rendering/commit/7091c94772686fefb5e17d245b40585b5515bd0e.patch?full_index=1"
    sha256 "065366eada1462d0a3fc504db198df6cb68aad9397a5753122913f6d9330c2c4"
  end

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
