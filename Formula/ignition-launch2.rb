class IgnitionLaunch2 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch2-2.3.1.tar.bz2"
  sha256 "984e2a5df03ca220960470b6b59728edf3cd570314fbad6435b67cb26c9b7e4e"
  license "Apache-2.0"
  revision 10

  head "https://github.com/gazebosim/gz-launch.git", branch: "ign-launch2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "40b0faf68768d724207c521583ec7a073c2effbcf102910df447bff1f4a0e845"
    sha256 monterey: "bcd0d8ec7118fe866a66b47aaf0c271c816f9a99096f5c6e5499343fe386b3a4"
  end

  deprecate! date: "2024-12-31", because: "is past end-of-life date"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "ffmpeg"
  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo3"
  depends_on "ignition-gui3"
  depends_on "ignition-msgs5"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport8"
  depends_on "protobuf"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system "ign", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
