class IgnitionCmake0 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "https://osrf-distributions.s3.amazonaws.com/ign-cmake/releases/ignition-cmake-0.6.1.tar.bz2"
  sha256 "60745d5637a790a244b68c848ded6dd78acb11b542ae302d7ac9b7b629634064"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-cmake.git", branch: "ign-cmake0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, big_sur:  "5ba884848fec0b5c67381a26d2f8a115c89d17055ec9856a1f7f8ae1e708f6bb"
    sha256 cellar: :any_skip_relocation, catalina: "e81567c2b99f0f73f6b0938e0da4bfa1369f8e4905faee00c0f583f1139dbfd4"
    sha256 cellar: :any_skip_relocation, sierra:   "051534970fe3657c173e89d566b134a7e0185cc13afdac722817949594757691"
  end

  disable! date: "2024-08-31", because: "is past end-of-life date"
  deprecate! date: "2023-01-25", because: "is past end-of-life date"

  depends_on "cmake"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
      find_package(ignition-cmake0 REQUIRED)
      ign_configure_project(test 0.1.0)
      ign_configure_build(QUIT_IF_BUILD_ERRORS)
      #ign_create_packages()
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
