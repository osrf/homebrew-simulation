class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake2-2.1.0~pre1.tar.bz2"
  version "2.1.0~pre1"
  sha256 "e5c72d31574f875f9c43553bf85f91555e74889beea5e04a2364805e72f36f2e"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "506681700ebbbc62c923b95e6dcb96e3fd8994f86b79bbbcc8f2bbb5b3244f9f" => :mojave
    sha256 "b38bb7188ec3a6e4b050c4febfa3b62777f5982612a961956ba767d925ea6f47" => :high_sierra
    sha256 "a0c0b16d9d08272cdc1d4333b0ca6df6d0568c6b6eba3fba421da454bba3ec33" => :sierra
  end

  depends_on "cmake"
  depends_on "pkg-config"

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
