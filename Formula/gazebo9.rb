class Gazebo9 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-9.19.0.tar.bz2"
  sha256 "1f3ca430824b120ae0c7c4c0037a1a56e7b6bf6c50731b148b5c75bfc46d7fe7"
  license "Apache-2.0"

  head "https://github.com/osrf/gazebo.git", branch: "gazebo9"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "a5b3477c2a73a50313980eee7d2cb6f0242f549da6ceb73da3a399da4fd7b7e6"
    sha256 mojave:   "26998e6bfe7cbd1922c417ec4420e09f983fd92150f802b8ae1cad245a6e2d69"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "graphviz"
  depends_on "ignition-fuel-tools1"
  depends_on "ignition-math4"
  depends_on "ignition-msgs1"
  depends_on "ignition-transport4"
  depends_on "libtar"
  depends_on macos: :mojave # ogre1.9 missing in highsierra
  depends_on "ogre1.9"
  depends_on "ossp-uuid" => :linked
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt@5"
  depends_on "qwt"
  depends_on "sdformat6"
  depends_on "tbb@2020_u3"
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "zeromq" => :linked

  depends_on "bullet" => :recommended
  depends_on "dartsim" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "gts" => :recommended
  depends_on "simbody" => :recommended
  depends_on "gdal" => :optional
  depends_on "player" => :optional

  conflicts_with "gazebo7", because: "differing version of the same formula"
  conflicts_with "gazebo11", because: "differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    # keep this patch
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DQWT_WIN_INCLUDE_DIR=#{HOMEBREW_PREFIX}/lib/qwt.framework/Headers"
    cmake_args << "-DQWT_WIN_LIBRARY_DIR=#{HOMEBREW_PREFIX}/lib/qwt.framework"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # Test is broken. See https://github.com/osrf/homebrew-simulation/issues/1003
    # this used to show boost linking errors, but not anymore
    # system "#{bin}/gz", "sdf"

    # running this sample code seg-faults from boost filesystem
    # if a bottle rebuild is needed
    (testpath/"test.cpp").write <<-EOS
      #include <gazebo/gazebo.hh>
      int main() {
        gazebo::common::copyDir(".", "./tmp");
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
      find_package(gazebo QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      include_directories(${GAZEBO_INCLUDE_DIRS})
      target_link_libraries(test_cmake ${GAZEBO_LIBRARIES})
    EOS
    # system "pkg-config", "--cflags", "gazebo"
    # cflags = `pkg-config --cflags gazebo`.split
    # libs = `pkg-config --libs gazebo`.split
    # boost libs not properly generated in pkg-config file
    # disable test for now
    # see https://github.com/osrf/homebrew-simulation/issues/850
    # system ENV.cc, "test.cpp",
    #                *cflags,
    #                "-L#{lib}",
    #                *libs,
    #                "-lc++",
    #                "-o", "test"
    # system "./test"
    ENV.append_path "CPATH", Formula["tbb@2020_u3"].opt_include
    mkdir "build" do
      system "cmake", ".."
      system "make"
      # Test is broken. See https://github.com/osrf/homebrew-simulation/issues/1003
      # system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
