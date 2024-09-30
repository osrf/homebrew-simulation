class Gazebo11 < Formula
  desc "Gazebo robot simulator"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-11.14.0.tar.bz2"
  sha256 "7e9842c046c9e0755355b274c240a8abbf4e962be7ce7b7f59194e5f4b584f45"
  license "Apache-2.0"
  revision 34

  head "https://github.com/osrf/gazebo.git", branch: "gazebo11"

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
  depends_on "tinyxml1"
  depends_on "tinyxml2"
  depends_on "urdfdom"
  depends_on "zeromq" => :linked

  # depends on "gdal"
  # depends on "player"

  conflicts_with "gazebo9", because: "differing version of the same formula"
  conflicts_with "gz-tools2", because: "both install bin/gz"

  patch do
    # Fix build with boost 1.85.0
    # Remove this patch with the next release
    url "https://github.com/gazebosim/gazebo-classic/commit/e4b4d0fb752c7e43e34ab97d0e01a2a3eaca1ed4.patch?full_index=1"
    sha256 "c00fdff58d8e65945d480cb58006ff28bf2c22043373d709705420dc59b70f62"
  end

  patch do
    # Fix build with boost 1.86.0
    # Remove this patch with the next release
    url "https://github.com/gazebosim/gazebo-classic/commit/15cc7addd1ede775b713a59414477460a0b34a70.patch?full_index=1"
    sha256 "34dc182226c2ec7a3ae0289eb2089ca7bddc940869b5bff3a0572fc47fdbf0b0"
  end

  patch do
    # Fix build with ffmpeg 7.0
    # Remove this patch with the next release
    url "https://github.com/gazebosim/gazebo-classic/commit/d04e1e0e9473e3bbbc0ae6e3f62dcad682bf9fd9.patch?full_index=1"
    sha256 "b777204f2d5d4cb5c0f565947dd5b290b256eb1724d2498abae9e2bef7c5fe33"
  end

  patch do
    # Fix build with graphviz 10.0
    # Remove this patch with the next release
    url "https://github.com/gazebosim/gazebo-classic/commit/3a9efee7ccdf552cbf22188131782f242f6c0542.patch?full_index=1"
    sha256 "4c957a715263b11c91ceb9f1aed701257e8b67457abc00539a615b0b5b1c7ea2"
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
