class GzPlugin4 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-4.0.0.tar.bz2"
  sha256 "f33b784fd26ab856f976425f8aafcf3d8c76c694444f219b73b7a95882cc123a"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-plugin.git", branch: "gz-plugin4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "131ed9fa572d1f1785e0c19d57a039798bf61d1208780f44060d1e2f9ed4c1c4"
    sha256 cellar: :any, arm64_sonoma:  "a2643a7cfa988803739d584fbbbdec4411d7c2e7a1ec16efe99252a8d1fc5f0d"
    sha256 cellar: :any, sonoma:        "ad43e493f30babf6c7c337629b2ca19f100e66c2a5ac894c8868f1bc750f7220"
  end

  depends_on "cmake"
  depends_on "gz-cmake5"
  depends_on "gz-tools2"
  depends_on "gz-utils4"
  depends_on "pkgconf"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/plugin4", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test CLI executable
    system libexec/"gz/plugin4/gz-plugin"
    # build against API
    (testpath/"test.cpp").write <<-EOS
      #include <gz/plugin/Loader.hh>
      int main() {
        gz::plugin::Loader loader;
        return loader.InterfacesImplemented().size();
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-plugin QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-plugin::loader)
    EOS
    system "pkg-config", "gz-plugin-loader"
    cflags = `pkg-config --cflags gz-plugin-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-plugin-loader",
                   "-lc++",
                   "-o", "test"
    system "./test"
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
