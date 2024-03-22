class ChronoEngine < Formula
  desc "Chrono physics engine"
  homepage "http://www.projectchrono.org"
  url "https://github.com/projectchrono/chrono/archive/refs/tags/7.0.3.tar.gz"
  sha256 "335923458fc75024baf2458c94d9d227da6ee91f989f5603b2d13498e2db0a81"
  license "BSD-3-Clause"

  head "https://github.com/projectchrono/chrono.git", branch: "main"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, monterey: "94b34bcbec8cd55e261c8bdaee60fb9ea46b1351fff05c35408736bb155d1468"
    sha256 cellar: :any, big_sur:  "eed9074244be5f8a1ba35aa3924bf2c739fae5e97a69bf2cfdbc924d26ad98d6"
    sha256 cellar: :any, catalina: "079fe5fa4d3ec345cd8b51fd54f0ed4124e09aff7d059c48b43e9656b67b2675"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "eigen" => [:build, :test]
  depends_on "irrlicht"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DENABLE_MODULE_IRRLICHT=ON"
    cmake_args << "-DENABLE_MODULE_POSTPROCESS=ON"

    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end

    # Put cmake config file in easier to find location
    # Remove these lines after the following PR is merged and released
    # https://github.com/projectchrono/chrono/pull/421
    (lib/"cmake/Chrono").install Dir[lib/"cmake/*.cmake"]
    rm Dir[lib/"cmake/*.cmake"]
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include "chrono/core/ChVector.h"
      int main()
      {
        chrono::ChVector<float> v(1.1f, -2.2f, 3.3f);
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
	    set(CMAKE_CXX_STANDARD 14)
      find_package(Eigen3 ${EIGEN3_FIND_VERSION} CONFIG)
      find_package(Chrono REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake ${CHRONO_LIBRARIES} Eigen3::Eigen)
    EOS
    # test building with cmake
    mkdir "build" do
      system "cmake", ".."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
