class GzMsgs10 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-10.3.0.tar.bz2"
  sha256 "501e475f5602448428a11d16e3d11972a87d5212bd1655d9154e74aa80bd8454"
  license "Apache-2.0"
  revision 4

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "de40c0ea62f2ab67d876dac3479f1f9c1bc2f830297466ef5ee95f18496c300e"
    sha256 monterey: "62dd57175dee4f237f84403715dc7e757c9d1f614f8e5d3746fe8bf4deca3701"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-tools2"
  depends_on "gz-utils2"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "python@3.12"
  depends_on "tinyxml2"

  def python_cmake_arg
    "-DPython3_EXECUTABLE=#{which("python3")}"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"
    cmake_args << python_cmake_arg

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.12/site-packages").install Dir[lib/"python/*"]
    rmdir prefix/"lib/python"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <gz/msgs.hh>
      int main() {
        gz::msgs::UInt32;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10 FATAL_ERROR)
      find_package(gz-msgs10 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-msgs10::gz-msgs10)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-msgs10"
    cflags = `pkg-config --cflags gz-msgs10`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-msgs10",
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
    # check python import
    system Formula["python@3.12"].opt_bin/"python3", "-c", "import gz.msgs10"
  end
end
