class GzUtils3 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/gz-utils/releases/gz-utils-3.0.0~pre3.tar.bz2"
  version "3.0.0-pre3"
  sha256 "2abf8313b3977bcc2c989f1d6786863a0edc44a19872a87ad966ea2f9420bbe2"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, sonoma:   "9d37c6062359e2e563dd1947a8708013f9dcd6cf07121878e1e963018d09abcd"
    sha256 cellar: :any, ventura:  "d0e14175573736f668c7239475e88325135d04054cf0f0ea08286f80f1489a13"
    sha256 cellar: :any, monterey: "1765307a56d3c3f90e00b5636dd5de78403fe0c92f175120644968793fb40707"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "gz-cmake4"
  depends_on "spdlog"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <gz/utils/ImplPtr.hh>
      class SomeClassPrivate
      {
      };
      class SomeClass
      {
        private: gz::utils::ImplPtr<SomeClassPrivate> dataPtr =
            gz::utils::MakeImpl<SomeClassPrivate>();
      };
      int main() {
        SomeClass object;
        return 0;
      }
    EOS
    (testpath/"CMakeLists.txt").write <<-EOS
      cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
      find_package(gz-utils3 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-utils3::gz-utils3)
    EOS
    system "pkg-config", "gz-utils3"
    cflags = `pkg-config --cflags gz-utils3`.split
    ldflags = `pkg-config --libs gz-utils3`.split
    system ENV.cxx, "test.cpp",
                    *cflags,
                    *ldflags,
                    "-o", "test"
    system "./test"
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
