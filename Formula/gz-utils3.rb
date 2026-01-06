class GzUtils3 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/gz-utils/releases/gz-utils-3.1.1.tar.bz2"
  sha256 "161942a2d00c820683cf88e41c48545e8da4c959aad77ca2229021e5f961201d"
  license "Apache-2.0"
  revision 6

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, arm64_sequoia: "bcac4cdd77ebd706fd314551136a2f8d31e11a6831f8040c2c39d98b2ddd2b55"
    sha256 cellar: :any, arm64_sonoma:  "4b43ea96d59ca07b369c22f0ca150b7e465acc153a770048b15ac30330e19ded"
    sha256 cellar: :any, sonoma:        "b89e45ad797d1cafae9ccfc14502a849cfe2d998d4c2829ecca7fba6c04e6823"
  end

  # head "https://github.com/gazebosim/gz-utils.git", branch: "gz-utils3"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "cli11"
  depends_on "gz-cmake4"
  depends_on "spdlog"

  def install
    cmake_args = std_cmake_args
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
