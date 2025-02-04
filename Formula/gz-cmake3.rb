class GzCmake3 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://gazebosim.org"
  url "https://osrf-distributions.s3.amazonaws.com/gz-cmake/releases/gz-cmake-3.5.4.tar.bz2"
  sha256 "284ccf76b9b928e005f0b9339b3ee2cfe7e81b9f72b3f240c0e545ca2727885e"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-cmake.git", branch: "gz-cmake3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any_skip_relocation, sonoma:  "90f555bdc6dd841e1bd399e6ddc7b76cf1416282335a2b861ff15be497c2021a"
    sha256 cellar: :any_skip_relocation, ventura: "09dfe1629d92929edcfc0dbf5c300fbc18c50d2f46d1241a784d03566b5f8481"
  end

  depends_on "cmake"
  depends_on "pkgconf"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"

    # Use build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5.1 FATAL_ERROR)
      project(gz-test VERSION 0.1.0)
      find_package(gz-cmake3 REQUIRED)
      gz_configure_project()
      gz_configure_build(QUIT_IF_BUILD_ERRORS)
    EOS
    # Create necessary cmake files
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
