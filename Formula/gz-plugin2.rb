class GzPlugin2 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-2.0.3.tar.bz2"
  sha256 "62c45931283afd06b5e3cb55d87c4f75cf549b788aabc4a20c008cb1e898fb37"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-math.git", branch: "gz-math7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:   "feb89201d285238c72e68291ea9da024c47c7bb36ca493ff4de0270b96e562e1"
    sha256 cellar: :any, ventura:  "639e07042fa87ee6ce1e59be3efa121c07b8617b2d436ca6a67bbeddd1ff85b9"
    sha256 cellar: :any, monterey: "d626ae1bcd4bbfc727d1afe9cfa4a9230b632169ba1bbf317cb9154dd08966df"
  end

  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/plugin2", target: lib),
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
    system libexec/"gz/plugin2/gz-plugin"
    # build against API
    (testpath/"test.cpp").write <<-EOS
      #include <gz/plugin/Loader.hh>
      int main() {
        gz::plugin::Loader loader;
        return loader.InterfacesImplemented().size();
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-plugin2 QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-plugin2::loader)
    EOS
    system "pkg-config", "gz-plugin2-loader"
    cflags = `pkg-config --cflags gz-plugin2-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-plugin2-loader",
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
