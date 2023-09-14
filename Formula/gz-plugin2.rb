class GzPlugin2 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-2.0.1.tar.bz2"
  sha256 "92b5c9a99b611887b40c271bf47300b4e8a5d006aa80902bd705d36f1d8508f5"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-math.git", branch: "gz-math7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "0cccfc4e784821706358e8e91655d231c5378fa950ee02775d2917522f9da41f"
    sha256 cellar: :any, monterey: "f5a33572b7400a2948ae1c988be41ee08f9c3f0a4217e7361fcca263b8290ed0"
    sha256 cellar: :any, big_sur:  "696b7c7ed4768f14eb5ba56fa393f087571f238873c4681caac6ac6c711169d5"
    sha256 cellar: :any, catalina: "c7faa3c09ae61b955b32e2c959a586fd61fb73a03f90282f5d3f29a2e8af71b1"
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

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    system "#{libexec}/gz/plugin2/gz-plugin"
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
