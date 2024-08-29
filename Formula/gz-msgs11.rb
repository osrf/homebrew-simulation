class GzMsgs11 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-11.0.0~pre1.tar.bz2"
  version "11.0.0-pre1"
  sha256 "6f96ae7e09b84d890383157f5e8b0509a0ccdf5abe8216fae7a1c7bc1aa80654"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "09574aaf80684d0f260135a8b41627ae3e09fd1aec3495383f25a1b477fc9177"
    sha256 monterey: "4881830eb13e73cdb51e65b24843ba14f67ef79394c777887422fb4120c75b0e"
  end

  depends_on "abseil"
  depends_on "cmake"
  depends_on "gz-cmake4"
  depends_on "gz-math8"
  depends_on "gz-tools2"
  depends_on "gz-utils3"
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
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-msgs11 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-msgs11::gz-msgs11)
    EOS
    # test building with pkg-config
    system "pkg-config", "gz-msgs11"
    cflags = `pkg-config --cflags gz-msgs11`.split
    system ENV.cc, "test.cpp",
                   *cflags,
                   "-L#{lib}",
                   "-lgz-msgs11",
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
    system Formula["python@3.12"].opt_bin/"python3.12", "-c", "import gz.msgs11"
  end
end
