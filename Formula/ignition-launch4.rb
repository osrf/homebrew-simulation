class IgnitionLaunch4 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://github.com/ignitionrobotics/ign-launch/archive/7fa59b68cc8570add87819fbeb6c112474405894.tar.gz"
  version "3.999.999~0~20210112~7fa59b"
  sha256 "d3781dc7f6d50043cf8237bca061d276a629e55ae7b61818863893d7d86af9f2"
  license "Apache-2.0"
  revision 1

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 mojave: "2009896d82042bb346d504b378f9b38d879c2374ed3c1b301f3aa3136bf6ffbf"
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
