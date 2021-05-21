class IgnitionLaunch2 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch2-2.2.1.tar.bz2"
  sha256 "a44f3d874acd2e91323a48eba817fafe9a4c5f04860b4543677241bbbe5041dc"
  license "Apache-2.0"
  revision 2

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "ign-launch2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "8711324583f58b4d77c07fb3b27dde22ca267d9c8bf52a1331f0b079a6311579"
    sha256 mojave:   "25ef6aa07f567cc563dcafd5e0bd2cce04966ef5f99585dcd07967a1daead7ef"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo3"
  depends_on "ignition-gui3"
  depends_on "ignition-msgs5"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport8"
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
