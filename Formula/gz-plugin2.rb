class GzPlugin2 < Formula
  desc "Plugin libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-plugin"
  url "https://osrf-distributions.s3.amazonaws.com/gz-plugin/releases/gz-plugin-2.0.4.tar.bz2"
  sha256 "5c4471d77930cf53b47014d1082702a433f18fdcd7796cad6c23c52595ebec19"
  license "Apache-2.0"

  # head "https://github.com/gazebosim/gz-math.git", branch: "gz-math7"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:  "92833e720822a18291ddce53b0b24d159d544f48e988ecf4560fa33f11a52c05"
    sha256 cellar: :any, ventura: "b4ff9bce1e706cd433da44f40ae739a27ab2f75fe91a6f93885f291cabd7ee93"
  end

  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :high_sierra # c++17
  depends_on "pkgconf"

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
