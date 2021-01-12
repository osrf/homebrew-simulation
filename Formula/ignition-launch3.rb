class IgnitionLaunch3 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch3-3.1.1.tar.bz2"
  sha256 "7de66c18b14388f4679488bc76bff0a7528ef59e0c3faf6c50713a2a40a5217c"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-launch", branch: "ign-launch3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 "dbeac3991a09b9fa8a51b3403781c7a8dfcd3e7742b9e2a114f10f9d3648165c" => :mojave
  end

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
