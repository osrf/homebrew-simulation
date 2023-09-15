class GzLaunch6 < Formula
  desc "Launch libraries for robotics applications"
  homepage "https://github.com/gazebosim/gz-launch"
  url "https://osrf-distributions.s3.amazonaws.com/gz-launch/releases/gz-launch-6.0.0.tar.bz2"
  sha256 "e59e988c8a454cacc9f8f5727d1ab0d2c7fc8476083ec96065a0f89913957b0a"
  license "Apache-2.0"
  revision 12

  head "https://github.com/gazebosim/gz-launch.git", branch: "gz-launch6"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 ventura:  "2f96f79801cc21752c16a6df71ccfe6f996bb4c68848243dbaf309cd8e2c6056"
    sha256 monterey: "495fbcf7ed3c849d0e2a16af7e727916ae130ec016036e6a8164b1ad40295606"
    sha256 big_sur:  "454cb15efa59ab3a2344e90b91b7f950a7636f48db5d8951e94826a6ab545862"
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
    rpaths = [
      rpath,
      rpath(source: lib/"gz/launch6", target: lib),
      rpath(source: lib/"gz-launch-6/plugins", target: lib),
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
    system lib/"gz/launch6/gz-launch"
    # test plugins in subfolders
    %w[joytotwist sim-factory sim simgui].each do |plugin|
      p = lib/"gz-launch-6/plugins/libgz-launch-#{plugin}.dylib"
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
    ENV["GZ_CONFIG_PATH"] = "#{opt_share}/gz"
    system "gz", "launch", "--versions"
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
