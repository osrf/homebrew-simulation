class Gazebo11 < Formula
  desc "Gazebo robot simulator"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-11.13.0.tar.bz2"
  sha256 "2f65b98fe652a574e01b7cae6cf12e14a9dd29343fde99e066ac5193a8d03e71"
  license "Apache-2.0"
  revision 10

  head "https://github.com/osrf/gazebo.git", branch: "gazebo11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "0e8dc76027a24af5abe12e7ccff9d5ce54e8b1bfb73b844d9129708ef156a9ba"
    sha256 monterey: "919c1c1a409b364ad9e7339f95e4203b83918444adf1e0b4310fccf8ac485a05"
    sha256 big_sur:  "36b520e1b998fd1801ae0ec9e4812e926bfc54133275a56336c3d49d06d83518"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "bullet"
  depends_on "dartsim"
  depends_on "doxygen"
  depends_on "ffmpeg"
  depends_on "freeimage"
  depends_on "graphviz"
  depends_on "gts"
  depends_on "ignition-common3"
  depends_on "ignition-fuel-tools4"
  depends_on "ignition-math6"
  depends_on "ignition-msgs5"
  depends_on "ignition-transport8"
  depends_on "libtar"
  depends_on "ogre1.9"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "qwt-qt5"
  depends_on "sdformat9"
  depends_on "simbody"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "zeromq" => :linked

  # depends on "gdal"
  # depends on "player"

  conflicts_with "gazebo7", because: "differing version of the same formula"
  conflicts_with "gazebo9", because: "differing version of the same formula"
  conflicts_with "gz-tools2", because: "both install bin/gz"

  patch do
    # Fix for compatibility with graphviz 9.0
    url "https://github.com/gazebosim/gazebo-classic/commit/ba2cbd532a8ba47972cf9f0c3dbc32a5757cab2a.patch?full_index=1"
    sha256 "a9cca7d59663fd45bab74e044c817600d24028e80ad2871107a34e8a3bebab2a"
  end

  patch do
    # Fix for compatibility with protobuf 23.2
    url "https://github.com/gazebosim/gazebo-classic/commit/17e09f574a4f39caff279cd70364cd1a3ea46f70.patch?full_index=1"
    sha256 "b50f4cbfe92d3ded2dd7117696cf6a049f0bbdcdb9ef8f54bbc6bde7670f51b3"
  end

  patch do
    # Fix build when homebrew python is installed
    # keep this patch
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DQWT_WIN_INCLUDE_DIR=#{Formula["qwt-qt5"].opt_lib}/qwt.framework/Headers"
    cmake_args << "-DQWT_WIN_LIBRARY_DIR=#{Formula["qwt-qt5"].opt_lib}/qwt.framework"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # use build folder
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
      #include <gazebo/gazebo.hh>
      int main() {
        gazebo::common::copyDir(".", "./tmp");
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
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
