class GzPlugin3 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-3.0.1.tar.bz2"
  sha256 "13ef38f6feb4f9877f578aefadb0cdc330495bf21634714fa84fe004c6070228"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-plugin.git", branch: "gz-plugin3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "5038d101899f30c46fe4fc616b601decd0ebd0b1799bc3e5553383be0a0176cf"
    sha256 cellar: :any, ventura: "68522ecc219ca8970bfaad2bd5005b12f9809ef381fdd6d6647491a8f467b77e"
  end

  depends_on "cmake"
  depends_on "gz-cmake4"
  depends_on "gz-tools2"
  depends_on "gz-utils3"
  depends_on macos: :high_sierra # c++17
  depends_on "pkgconf"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/plugin3", target: lib),
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
    system libexec/"gz/plugin3/gz-plugin"
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
      find_package(gz-plugin3 QUIET REQUIRED COMPONENTS loader)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-plugin3::loader)
    EOS
    system "pkg-config", "gz-plugin3-loader"
    cflags = `pkg-config --cflags gz-plugin3-loader`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-plugin3-loader",
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
