class Gazebo9 < Formula
  desc "Gazebo robot simulator"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gazebo/releases/gazebo-9.19.0.tar.bz2"
  sha256 "1f3ca430824b120ae0c7c4c0037a1a56e7b6bf6c50731b148b5c75bfc46d7fe7"
  license "Apache-2.0"
  revision 23

  head "https://github.com/osrf/gazebo.git", branch: "gazebo9"

  deprecate! date: "2023-01-25", because: "is past end-of-life date"
  disable! date: "2024-08-31", because: "is past end-of-life date"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "boost"
  depends_on "bullet"
  depends_on "cmake@3.21.4"
  depends_on "dartsim"
  depends_on "doxygen"
  depends_on "ffmpeg@4"
  depends_on "freeimage"
  depends_on "graphviz"
  depends_on "gts"
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
  depends_on "qwt-qt5"
  depends_on "sdformat6"
  depends_on "simbody"
  depends_on "tbb@2020_u3"
  depends_on "tinyxml"
  depends_on "tinyxml2"
  depends_on "zeromq" => :linked

  # depends on "gdal" => :optional
  # depends on "player" => :optional

  conflicts_with "gazebo11", because: "differing version of the same formula"
  conflicts_with "gz-tools2", because: "both install bin/gz"

  patch do
    # Fix build when homebrew python is installed
    # keep this patch
    url "https://gist.githubusercontent.com/scpeters/9199370/raw/afe595587e38737c537124a3652db99de026c272/brew_python_fix.patch"
    sha256 "c4774f64c490fa03236564312bd24a8630963762e25d98d072e747f0412df18e"
  end

  patch do
    # Fix for compatibility with qwt 6.2
    url "https://github.com/osrf/gazebo/commit/9e7e9bfbace6e0cc3f06842bb1efd47eb0632b36.patch?full_index=1"
    sha256 "625d7f990629e431ef160ac771b632f9007b72d0608e7bccd4a7e0987417a347"
  end

  patch do
    # Fix compilation: add missing std namespace
    # https://github.com/gazebosim/gz-msgs/pull/242
    # TODO: remove with next major release
    url "https://github.com/osrf/gazebo/commit/2f0f7af4868883d1a6fea30086b3fcd703d583fc.patch?full_index=1"
    sha256 "08082b1c7ff191e6b28472a9eead708d21e56124f2672ac3d12a577734572101"
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
    ENV.append_path "CMAKE_PREFIX_PATH", Formula["ffmpeg@4"].opt_prefix
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
