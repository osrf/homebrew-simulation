class GzUtils4 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/gz-utils/releases/gz-utils-4.0.0~pre1.tar.bz2"
  version "4.0.0-pre1"
  sha256 "4070d0756ac2a555a8c2f4f559b100f2e85ec701efe6fbea3aab9f5cb61589cd"
  license "Apache-2.0"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sonoma: "f4464eaaa50af0c4691b197e2b7d11672316717642a8f606762d5d9ce4a613f3"
    sha256 cellar: :any, sonoma:       "e5c93a09e9bb33700ef862616ad58d0521e37392e12d7c4f8ffb2bcf1d36fa98"
    sha256 cellar: :any, ventura:      "059b98331dfd901b69a47086d6a186a5283a13c65a92dae36870b4d9cef6de59"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "cli11"
  depends_on "gz-cmake5"
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
      find_package(gz-utils QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-utils::gz-utils)
    EOS
    system "pkg-config", "gz-utils"
    cflags = `pkg-config --cflags gz-utils`.split
    ldflags = `pkg-config --libs gz-utils`.split
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
