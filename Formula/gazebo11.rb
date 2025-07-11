class Gazebo11 < Formula
  desc "Gazebo robot simulator"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-11.15.0.tar.bz2"
  sha256 "8998ef927b424ac24ae6eaea4e69b0d0640877059cba8680d20cd526e6333262"
  license "Apache-2.0"
  revision 6

  head "https://github.com/osrf/gazebo.git", branch: "gazebo11"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 sonoma:  "074e08d3b0e44475ffb0f159cdf599c30ee6b37b6a8e2bb0dbada457d73a3581"
    sha256 ventura: "d4376884717e4f5e49e453f00ff13b1e10c3322ed9a94e5dde5de008567538ef"
  end

  deprecate! date: "2025-01-31", because: "is past end-of-life date"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "boost@1.85.0"
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
  depends_on "ogre1.9-with-boost1.85"
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

  conflicts_with "gz-tools2", because: "both install bin/gz"
  conflicts_with "gz-tools3", because: "both install bin/gz"

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
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["boost@1.85.0"].opt_prefix
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["ogre1.9-with-boost1.85"].opt_prefix
    ENV.append_path "PKG_CONFIG_PATH", Formula["ogre1.9-with-boost1.85"].opt_lib/"pkgconfig"
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
