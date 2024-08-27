class GzPlugin3 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-3.0.0~pre1.tar.bz2"
  version "3.0.0-pre1"
  sha256 "c442a83657b18eaf000921740bc5e231a3d662949551c431e2fcff28803f4c93"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-plugin.git", branch: "gz-plugin3"

  depends_on "cmake"
  depends_on "gz-cmake4"
  depends_on "gz-tools2"
  depends_on "gz-utils3"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"

  def install
    rpaths = [
      rpath,
      rpath(source: libexec/"gz/plugin3", target: lib),
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
