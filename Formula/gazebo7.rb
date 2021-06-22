class Gazebo7 < Formula
  desc "Gazebo robot simulator"
  homepage "http://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-7.16.0.tar.bz2"
  sha256 "c6e5f27b9bfa2494a02dd34d567869c5431659895dea3aca22dc15df6716cf4f"
  license "Apache-2.0"
  revision 3

  head "https://github.com/osrf/gazebo.git", branch: "gazebo7"

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]

  depends_on "boost"
  depends_on "cartr/qt4/qt@4"
  depends_on "doxygen"
  depends_on "freeimage"
  depends_on "graphviz"
  depends_on "ignition-math2"
  depends_on "libtar"
  depends_on "ogre1.9"
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "sdformat4"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"

  depends_on "bullet" => :recommended
  depends_on "ffmpeg" => :recommended
  depends_on "gts" => :recommended
  depends_on "simbody" => :recommended
  depends_on "dartsim/dart/dartsim4" => :optional
  depends_on "gdal" => :optional
  depends_on "player" => :optional

  conflicts_with "gazebo2", because: "differing version of the same formula"
  conflicts_with "gazebo3", because: "differing version of the same formula"
  conflicts_with "gazebo4", because: "differing version of the same formula"
  conflicts_with "gazebo5", because: "differing version of the same formula"
  conflicts_with "gazebo6", because: "differing version of the same formula"
  conflicts_with "gazebo8", because: "differing version of the same formula"
  conflicts_with "gazebo9", because: "differing version of the same formula"
  conflicts_with "gazebo11", because: "differing version of the same formula"

  patch do
    # Fix build when homebrew python is installed
    # keep this patch
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Fix gts linking
    url "https://github.com/osrf/gazebo/commit/6178c06666102fc81958bd2f20b0cd2e04f854cb.patch?full_index=1"
    sha256 "0a5be79760c6099cefe12fc91ed0db161147d92f51186c074d866c63f35ca288"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_TESTS_COMPILATION:BOOL=False"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # this used to show boost linking errors, but not anymore
    system "#{bin}/gz", "sdf"
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
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
