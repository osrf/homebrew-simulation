class GzUtils3 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/gz-utils/releases/gz-utils-3.2.0.tar.bz2"
  sha256 "a0c72074162959a68bff9318d67247b3f789c49959ac41eed687e008c83c0ebd"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-utils.git", branch: "gz-utils3"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_tahoe:   "b1786a95acfc67e1535615c6b3618f651efe03dd53a1847260ba1a320aa46c23"
    sha256 cellar: :any, arm64_sequoia: "9210a56fdad2e2c10bb7151a991d750bfc466524fc90d7e76016fa5066ad68cc"
  end

  deprecate! date: "2026-12-15", because: :deprecated_upstream

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "cli11"
  depends_on "fmt"
  depends_on "gz-cmake4"
  depends_on "spdlog"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use a build folder
    mkdir "build" do
      system "cmake", "-S", "..", "-B", ".", *cmake_args
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
      system "cmake", "-S", "..", "-B", "."
      system "make"
      system "./test_cmake"
    end
    # check for Xcode frameworks in bottle
    cmd_not_grep_xcode = "! grep -rnI 'Applications[/]Xcode' #{prefix}"
    system cmd_not_grep_xcode
  end
end
