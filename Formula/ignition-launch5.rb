class IgnitionLaunch5 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/ign-launch/releases/ignition-launch5-5.3.0.tar.bz2"
  sha256 "84d356b9c85609da1bb7feda2f90ae6d1a1fd2d6713b284799d5605de42e2613"
  license "Apache-2.0"
  revision 63

  head "https://github.com/gazebosim/gz-launch.git", branch: "ign-launch5"

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build

  depends_on "gz-plugin2" => :test

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

  patch do
    # Fix for m1 processor
    url "https://github.com/gazebosim/gz-launch/commit/ae261dc1d8f8c1a1f868b21054ccda659df68a01.patch?full_index=1"
    sha256 "eeb5a263154c9a946c9021eb847e0a01f9788daf3c1c31522c5115973c46710f"
  end

  patch do
    # Fix for compatibility with protobuf 30
    url "https://github.com/gazebosim/gz-launch/commit/b2ad7b5210271dbb2388b91d5610d6086a912e0f.patch?full_index=1"
    sha256 "4d2e12dd78d6c44840304d16031df505c7a58d61fd2630e7b4c471b8081a15cf"
  end

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
    require "system_command"
    extend SystemCommand::Mixin
    # test CLI executable
    system lib/"ignition/launch5/ign-launch"
    # test plugins in subfolders
    %w[joytotwist gazebo-factory gazebo gazebogui].each do |plugin|
      p = lib/"ign-launch-5/plugins/libignition-launch-#{plugin}.dylib"
      # Use gz-plugin --info command to check plugin linking
      cmd = Formula["gz-plugin2"].opt_libexec/"gz/plugin2/gz-plugin"
      args = ["--info", "--plugin"] << p
      # print command and check return code
      system cmd, *args
      # check that library was loaded properly
      _, stderr = system_command(cmd, args:)
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
