class IgnitionLaunch4 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://github.com/ignitionrobotics/ign-launch/archive/a097685e4008b1c0331f30d6341ab6e6ea31ed58.tar.gz"
  version "3.999.999~0~20210111~a09768"
  sha256 "74250cfafdbe23103282f142b61049ef408af4b5244b35bceb235c6f7669f46c"
  license "Apache-2.0"
  revision 1

  head "https://github.com/ignitionrobotics/ign-launch", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "dcea3d3f3d84440e3f958c8732042fea1e506d07ec0ed603b03c7849175cda25" => :mojave
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
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
