class IgnitionLaunch4 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://github.com/ignitionrobotics/ign-launch/archive/ef97b8ab3693c5296905bf1982f676d316ecaca1.tar.gz"
  version "3.999.999~0~20210122~ef97b8"
  sha256 "03c09504483cd178b3ce48a4df1ca545d7efd85ced56410e08cffe3a18c59be2"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "48104157bce762651adcd16c6bebcafffaa41b475a3e714f30e39d7889d4b91b"
    sha256 mojave:   "12934d72c1d7c205a29394a8a0945e2c7cd0988282d9b9d2382d8356a49dfe3b"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common4"
  depends_on "ignition-gazebo5"
  depends_on "ignition-gui5"
  depends_on "ignition-msgs7"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport10"
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
