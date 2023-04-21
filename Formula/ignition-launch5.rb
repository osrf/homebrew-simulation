class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch5-5.2.0.tar.bz2"
  sha256 "30fbddd115423c8d6ba22d754f9a569dabc79f05316feb0347b72b55884be5de"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-launch.git", branch: "ign-launch5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 monterey: "3cc5a1d0910b01ba3bb990be5f7acac38f776fd617bd55efa217460ccee470a0"
    sha256 big_sur:  "0338761c4de92399ec293d3aeb1040be23724d05cf4254fa8942a8850285d15f"
    sha256 catalina: "2ffbf9b7d23f542259c72f2d20d3c2de6d0d7918714ba6d0ed66a716a0340fb8"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ffmpeg"
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
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system "ign", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
