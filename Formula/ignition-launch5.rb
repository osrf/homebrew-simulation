class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch5-5.3.0.tar.bz2"
  sha256 "84d356b9c85609da1bb7feda2f90ae6d1a1fd2d6713b284799d5605de42e2613"
  license "Apache-2.0"
  revision 8

  head "https://github.com/gazebosim/gz-launch.git", branch: "ign-launch5"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "03009f4bbecb8ca07df777c329fa4f1fad915ec27f28df82698941641d4a81ad"
    sha256 monterey: "3579468be3c929957bd0b250a490e5eaebb9780ada8d20e90943c29759d1caa7"
    sha256 big_sur:  "6b72248e6f4e0d8a7400a7455d16a09bf9eb3a8b9d38f0a2a32f0a4f40df9313"
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
    rpaths = [
      rpath,
      rpath(source: lib/"ignition/launch5", target: lib),
      rpath(source: lib/"ign-launch-5/plugins", target: lib),
    ]
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpaths.join(";")}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    # test CLI executable
    system lib/"ignition/launch5/ign-launch"
    # test plugins in subfolders
    ["joytotwist", "gazebo-factory", "gazebo", "gazebogui"].each do |plugin|
      p = lib/"ign-launch-5/plugins/libignition-launch-#{plugin}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args: args)
      error_string = "Error while loading the library"
      assert stderr.exclude?(error_string), error_string
    end
    ENV["IGN_CONFIG_PATH"] = "#{opt_share}/ignition"
    system "ign", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
