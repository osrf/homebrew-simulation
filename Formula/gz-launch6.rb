class GzLaunch6 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-6.0.0.tar.bz2"
  sha256 "e59e988c8a454cacc9f8f5727d1ab0d2c7fc8476083ec96065a0f89913957b0a"
  license "Apache-2.0"
  revision 11

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "d5a96d60b2b517a0f23dde7e6ac4999b989b757e40423b5dcd793c34cb7e701a"
    sha256 monterey: "58433548d9a79aecc23936ded43294bd5daa28a4c7264e7940c2d825f4a1fd93"
    sha256 big_sur:  "abbb98550806133ba6dc130ce896d32a7e0c2a24d05d7790f884e61810c55911"
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
