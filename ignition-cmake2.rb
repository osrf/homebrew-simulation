class IgnitionCmake2 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://bitbucket.org/ignitionrobotics/ign-cmake/get/6de1e2ffb2676a0356dac694e52144bcfaf1aad6.tar.gz"
  version "1.999.999~20180607~6de1e2f"
  sha256 "5a93a14a16fea03497c3a49def5357231a0f86e5e0b591f1c50cb85edacaa7cf"

  bottle do
    root_url "http://gazebosim.org/distributions/ign-cmake/releases"
    cellar :any_skip_relocation
    sha256 "f74c903035c179b2ef4422b71c9dfc2f2ecc1a1f131832fb373d92a8886aa8de" => :el_capitan_or_later
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
  end
end
