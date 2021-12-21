class IgnitionLaunch3 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch3-3.4.2.tar.bz2"
  sha256 "e4d8d4f91f9409a8ecdc139b0637564c94179b6abf8857f7b6eb983337c780ed"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "ign-launch3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "17e55745b34f4e077c90e7e1bad490c1b9d699a186660d3aa60a26d38bbb9440"
    sha256 catalina: "85267cf4d3b8682dacbb3ace2aa8e4bccf596ed7b6d679fd22eecd251950f5d2"
  end

  disable! date: "2022-01-31", because: "is past end-of-life date"

  deprecate! date: "2021-12-31", because: "is past end-of-life date"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ignition-cmake2"
  depends_on "ignition-common3"
  depends_on "ignition-gazebo4"
  depends_on "ignition-gui4"
  depends_on "ignition-msgs6"
  depends_on "ignition-plugin1"
  depends_on "ignition-tools"
  depends_on "ignition-transport9"
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
