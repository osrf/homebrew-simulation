class IgnitionLaunch3 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/ignitionrobotics/ign-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch3-3.4.2.tar.bz2"
  sha256 "e4d8d4f91f9409a8ecdc139b0637564c94179b6abf8857f7b6eb983337c780ed"
  license "Apache-2.0"

  head "https://github.com/ignitionrobotics/ign-launch.git", branch: "ign-launch3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 catalina: "1c214342be4970d64a36d061beccf09f3738fa7f0523cbd2d3fb8f9163fa4bf0"
    sha256 mojave:   "2ad6e74813a1df1ed60e55335ace450c2e5409439b6f74a4402a339970c49d9c"
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
