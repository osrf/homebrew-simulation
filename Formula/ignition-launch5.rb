class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://github.com/ignitionrobotics/ign-launch/archive/6fa0926a2dcc133f70b79abe30e83bd6ada23ad5.tar.gz"
  version "4.999.999~0~20210413~6fa092"
  sha256 "2ff7b619177887eccc4ec852ad0d1d0ba9d0ec422a5291e79bebb10eb73a002b"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "8eb4b50db0432b1cc03d43e4b10a49d771e608ac5e120f08992e4ca5903e3ab2"
    sha256 mojave:   "04bda45e757a1242c303494cdd835a668f1c90fc1a0412df14a970dbdd83443c"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-gazebo6"
  depends_on "ignition-gui6"
  depends_on "ignition-msgs8"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport11"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system "ign", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
