class GzLaunch6 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-6.0.0.tar.bz2"
  sha256 "e59e988c8a454cacc9f8f5727d1ab0d2c7fc8476083ec96065a0f89913957b0a"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 monterey: "81ab84e45ce0a91c949137a8fff80f0c90d49159d641016922a5c94e3ef521d7"
    sha256 big_sur:  "c536b1ffabdc5032d8eb15bea5ff402ed8dd7261abcf6f433e29923603741892"
    sha256 catalina: "109b1875e105519d453188742765ddeee31728c59f5df0d1e911f33366fa060b"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "ffmpeg"
  depends_on "gz-cmake3"
  depends_on "gz-common5"
  depends_on "gz-gui7"
  depends_on "gz-msgs9"
  depends_on "gz-plugin2"
  depends_on "gz-sim7"
  depends_on "gz-tools2"
  depends_on "gz-transport12"
  depends_on "qt@5"
  depends_on "tinyxml2"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath};/opt/homebrew/lib"

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
