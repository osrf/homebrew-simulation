class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake2-2.15.0.tar.bz2"
  sha256 "20a7b0c9e223db65fd3ed3c0a8e57ddafd93282c81badbf8bc3d493eeb5f37e6"
  license "Apache-2.0"
  revision 1

  head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, monterey: "e451deff4849f7260661da980a611d460897fef00927051d772255743d82cb9a"
    sha256 cellar: :any_skip_relocation, big_sur:  "ce7384690a4601962759d8e35edd43ef691ac0b487d942890f3d7bdc283f1804"
    sha256 cellar: :any_skip_relocation, catalina: "8ab2080f06710fe2c35abac662bc10fbc9e7d64aa7db8c5f3d627545a37668ec"
  end

  depends_on "cmake"
  depends_on "pkg-config"

  patch do
    # fix for PKG_CONFIG_PATH in FindIgnOGRE2
    url "https://github.com/gazebosim/gz-cmake/commit/038178552e56054c8908524df894dd818c50aa98.patch?full_index=1"
    sha256 "1fcc06ca3345f713aa38b2b2ccad3feb572817de468c2de3e660ab99f162def7"
  end

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
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
