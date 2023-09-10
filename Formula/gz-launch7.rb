class GzLaunch7 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-7.0.0~pre1.tar.bz2"
  version "7.0.0~pre1"
  sha256 "efe15fd7201079612ce69bd6d7cdc3a5694f302928838b9bb48a40459085e1e0"
  license "Apache-2.0"
  revision 2

  head "https://github.com/gazebosim/gz-launch.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "1eb930092c0b5fc49a5828fb7d91094ccf6a7d24a18a5fd8698c101d138a11b0"
    sha256 monterey: "72cbc00b70c5f119b0284be4d8966c0b61954d37466e95942afcea2bbf567bf6"
    sha256 big_sur:  "240ec8562fe42f5bca65924a14d085fa44fafcd03e23ba0da16c8c07f3e62942"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ffmpeg"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-gui8"
  depends_on "gz-msgs10"
  depends_on "gz-plugin2"
  depends_on "gz-sim8"
  depends_on "gz-tools2"
  depends_on "gz-transport13"
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
    ENV["GZ_CONFIG_PATH"] = "#{opt_share}/gz"
    system "gz", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
