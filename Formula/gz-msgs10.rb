class GzMsgs10 < Formula
  desc "Middleware protobuf messages for robotics"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-msgs/releases/gz-msgs-10.1.0.tar.bz2"
  sha256 "4f0463f5967314bcde63499a47ea88892d4b141c572910cc00fb415357f993d0"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-msgs.git", branch: "gz-msgs10"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "441ad071f0ac152807f8c3279582bb2d1cfec7134c732b2ed8f1e645def4176c"
    sha256 monterey: "e29fc851e1af7e7230ae312d8f97b7052994d316cdf65e4ec1b0c39b66393978"
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
