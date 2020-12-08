class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake2-2.6.0.tar.bz2"
  sha256 "059dda01b6c17cd987ffce6cee64d0418841bd5b18be27a2a807aa47f011f209"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "e6322224f0403c1438ae086fc3d84cc66afede6a3d8f552449f84eefb2549164" => :mojave
  end

  depends_on "cmake"
  depends_on "pkg-config"

  patch do
    # Fix for finding ogre2 Overlay library
    url "https://github.com/ignitionrobotics/ign-cmake/commit/6a646e9201d84d7945b6aad4c12b0fa43d6af6f0.patch?full_index=1"
    sha256 "893e4174b470e67f9ff0a41ac20d7642d79e00f14581355ec418098d995337b1"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
      project(ignition-test VERSION 0.1.0)
      find_package(ignition-cmake2 REQUIRED)
      ign_configure_project()
      ign_configure_build(QUIT_IF_BUILD_ERRORS)
    EOS
    %w[doc include src test].each do |dir|
      mkdir dir do
        touch "CMakeLists.txt"
      end
    end
    mkdir "build" do
      system "cmake", ".."
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
