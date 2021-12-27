class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch5-5.0.0.tar.bz2"
  sha256 "0c6b2ca8c9aa49f05af524a55b6068ad9b77ef2f5af8cddaec234bb047857354"
  license "Apache-2.0"
  revision 2

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "3f3405a9b4c9cbda2ba974c314897a1eae203c46c76c2d4b27ace8815422637c"
    sha256 catalina: "5216593413775fa1318cb5a5a99f1749f5b73b29b1f29e9ea148d7196f797226"
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
