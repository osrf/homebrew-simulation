class IgnitionCmake0 < Formula
  desc "CMake helper functions for building robotic applications"
  homepage "https://ignitionrobotics.org"
  url "http://gazebosim.org/distributions/ign-cmake/releases/ignition-cmake-0.6.1.tar.bz2"
  sha256 "60745d5637a790a244b68c848ded6dd78acb11b542ae302d7ac9b7b629634064"

  head "https://bitbucket.org/ignitionrobotics/ign-cmake", :branch => "ign-cmake0", :using => :hg

  bottle do
    root_url "http://gazebosim.org/distributions/bottles-simulation"
    cellar :any_skip_relocation
    sha256 "cb33a2f07754ac5f1a15f47011395aa6426f4a12f79f0b9ceeef6f56fbb1be67" => :mojave
    sha256 "07eb46753840c753d3275d82283f3f29132996f9420ad403e3a65b0f23e78871" => :high_sierra
    sha256 "051534970fe3657c173e89d566b134a7e0185cc13afdac722817949594757691" => :sierra
  end

  depends_on "cmake"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=Off"
    system "cmake", ".", *cmake_args
    system "make", "install"
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
  end
end
