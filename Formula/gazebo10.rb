class Gazebo10 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-10.2.0.tar.bz2"
  sha256 "47d8bfe70ffcde21cbc6dec142f3aecefaac66c63562aab6114f442f7ab27392"
  license "Apache-2.0"
  revision 7

  head "https://github.com/osrf/gazebo.git", branch: "gazebo10"

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
  depends_on "qt"
  depends_on "qwt"
  depends_on "sdformat6"
  depends_on "tbb"
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

  patch do
    # set CMP0100
    url "https://github.com/osrf/gazebo/commit/2e4f1b185cb46b2c06fe63881d60f3fbeb868923.patch?full_index=1"
    sha256 "77dd71e8aba1cdcffe015c79e6820b58084567a5c192dba775264a935b71d09b"
  end

  patch do
    # Fix for compatibility with boost 1.74
    url "https://github.com/osrf/gazebo/commit/c2fd34c00f4611d149aae5479dc4d98fe639805b.patch?full_index=1"
    sha256 "75ccd13714d39a0e1f1ecb882ad6fea1f15025d2e102fee79053fe88ef25bf4e"
  end

  patch do
    # Fix for compatibility with boost 1.73
    url "https://github.com/osrf/gazebo/commit/c55942ed348580317ea77312f7efce5c7937a49c.patch?full_index=1"
    sha256 "aa438923269ae1a2202d9b30fc9c0949c90925cebca352d24fb6400410e1e599"
  end

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
      #include <gazebo/common/CommonIface.hh>
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
