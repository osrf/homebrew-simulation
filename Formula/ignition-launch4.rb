class IgnitionLaunch4 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch4-4.0.0.tar.bz2"
  sha256 "55d93fee15b1d2d5d18d7160d89a58e1da325bbab109289f6168fd91ac1a3720"
  license "Apache-2.0"
  revision 1

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "ec1d5f998d92eb2a3d85de642c800180aacf1d11f33fff8053fef1469894378d"
    sha256 mojave:   "8ced849b2eae98a488af5740f2742bb3b61ffa13b0c758323c43b19a3f572d98"
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
