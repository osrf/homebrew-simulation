class GzMsgs10 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-10.0.0~pre4.tar.bz2"
  version "10.0.0-pre4"
  sha256 "3c5b847a0a2316196ff931d059afe0a8d378ca6e96f37784c9e227fe39f9a005"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "a9a96caa802ef2f1d934787647b0e57f3fbe93fcc3f7895c95fe2828d5f556d0"
    sha256 monterey: "a1d26e0c141d80dc2e986fac7ab124ecec5dcf0ade19adc90af035e322d2e982"
    sha256 big_sur:  "b3293701ab2cb15a4107a1988ac34b8b46b2336aff3bb38c7c3f08ad0944c315"
  end

  depends_on "cmake"
  depends_on "gz-cmake3"
  depends_on "gz-math7"
  depends_on "gz-tools2"
  depends_on macos: :high_sierra # c++17
  depends_on "pkg-config"
  depends_on "protobuf"
  depends_on "python@3.11"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    (lib/"python3.11/site-packages").install Dir[lib/"python/*"]
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
    system Formula["python@3.11"].opt_bin/"python3.11", "-c", "import gz.msgs10"
  end
end
