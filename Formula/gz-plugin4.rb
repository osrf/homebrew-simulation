class GzPlugin4 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-4.0.0.tar.bz2"
  sha256 "f33b784fd26ab856f976425f8aafcf3d8c76c694444f219b73b7a95882cc123a"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-plugin.git", branch: "gz-plugin4"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "0367acd4b42f938f16f98e68649ae73c2c52810c1f55a20d9a0fa3f6eff54c98"
    sha256 cellar: :any, arm64_sonoma:  "cee1fe7692532000196721be77d0f8501f05a8fc9dce636e6cd941483cbf2586"
    sha256 cellar: :any, sonoma:        "f6b9cd9f18fcda1dc17018fdaf2ef819d7f89195c13b974ff57ba3fd6af83f9a"
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
