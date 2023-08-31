class GzLaunch7 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-7.0.0~pre1.tar.bz2"
  version "7.0.0~pre1"
  sha256 "efe15fd7201079612ce69bd6d7cdc3a5694f302928838b9bb48a40459085e1e0"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-launch.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "a2118e97fbabc98f292367f43a17b4c95a3bf744e82f29bce329628680e685d7"
    sha256 monterey: "7bd740fd91b3b4afa16cecf4b443525a7c755bbacd92dd0827b64e56c57ee2c8"
    sha256 big_sur:  "f53daa0a64fe7a00c1f72150b4eb566c66d42531e04e1a399939997319de367e"
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
