class GzPlugin3 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-3.1.0.tar.bz2"
  sha256 "ec469900bda63b62367211c93d3baf6dd01629363003e70b1e67f6a714c446db"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-plugin.git", branch: "gz-plugin3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "77aaab2f0bff2ac77e8a5707d61aa32e12da0163895d6291bd3ad6804ffb9479"
    sha256 cellar: :any, ventura: "2d749e8dbc3f59c44eb4b0e0eb58036da4de18ec2598725638da973293116bf5"
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
