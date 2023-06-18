class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch5-5.3.0.tar.bz2"
  sha256 "84d356b9c85609da1bb7feda2f90ae6d1a1fd2d6713b284799d5605de42e2613"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-launch.git", branch: "ign-launch5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 monterey: "9c053e5fc38f024711df0c9b85db9f3a0038139a8ada68a3f7f64a19fa94d9cb"
    sha256 big_sur:  "67bb3be0b35e871c17e118a55606a13f8d8942b3ccd9dd7e790b405f393bd923"
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
  depends_on "protobuf"
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
