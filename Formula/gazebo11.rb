class Gazebo11 < Formula
  desc "Gazebo robot simulator"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-11.10.2.tar.bz2"
  sha256 "f6c4ea8cd8730c90b14760b3f84d4f362d3786b510fb43a0b77b2c06b8bdd2b6"
  license "Apache-2.0"

  head "https://github.com/osrf/gazebo.git", branch: "gazebo11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "0b78de4cf8e8f82b6309ff5ae2051a69b9b4211aaf70ef5f7bd5e71a12c80dc3"
    sha256 catalina: "0ab42c6f33ce0eaf8290662ce28b4d131ad2219bf1110258dcbf081b95eb6d1f"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "bullet"
  depends_on "cmake@3.21.4"
  depends_on "dartsim"
  depends_on "doxygen"
  depends_on "ffmpeg@4"
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
  depends_on "ossp-uuid" => :linked
  depends_on "protobuf"
  depends_on "protobuf-c"
  depends_on "qt@5"
  depends_on "qwt-qt5"
  depends_on "sdformat9"
  depends_on "simbody"
  depends_on "tbb"
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "zeromq" => :linked

  # depends on "gdal" => :optional
  # depends on "player" => :optional

  conflicts_with "gazebo7", because: "differing version of the same formula"
  conflicts_with "gazebo9", because: "differing version of the same formula"

  patch do
    # patch needed for the following tbb patch to apply
    url "https://github.com/osrf/gazebo/commit/34ebf4e4ee48d1a4e4f08d2f76fdb0a471717019.patch?full_index=1"
    sha256 "4984b897365c3c3bffd0a35df706621d822f61c1cf7ca6c0ac4f11f1cab7e108"
  end

  patch do
    # Fix build with new tbb
    # remove with next release
    url "https://github.com/osrf/gazebo/commit/ea956014ed45906dda21e1ee682d297189cb4a7b.patch?full_index=1"
    sha256 "24af2fc83aaf6816d289d588d7aa9142c9bd28eb9819f344d55770ee4fe9fd4c"
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
    ENV.append_path "CPATH", Formula["ffmpeg@4"].opt_include
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
