class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch5-5.2.0.tar.bz2"
  sha256 "30fbddd115423c8d6ba22d754f9a569dabc79f05316feb0347b72b55884be5de"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 big_sur:  "4fc04d4a1b7aa7cb3c62934c5156b96ec6bc60043ecb2d937fd31deb1b8a45a8"
    sha256 catalina: "5a8b7c71e8b6bc596cf0849b3133edf9273f98ba9774cc6930c0b3e26fbc0b2e"
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
