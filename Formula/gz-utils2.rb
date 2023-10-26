class GzUtils2 < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://osrf-distributions.s3.amazonaws.com/gz-utils/releases/gz-utils-2.2.0~pre3.tar.bz2"
  version "2.2.0-pre3"
  sha256 "1b864f391752b7c51251b3477dca5e6947dfbd20bc6daeb2732235ebcbff0bd3"
  license "Apache-2.0"

  head "https://github.com/gazebosim/gz-utils.git", branch: "gz-utils2"

  bottle do
    root_url "https://osrf-distributions.s3.amazonaws.com/bottles-simulation"
    sha256 cellar: :any, ventura:  "a3047cbc588580f096f5e1e4eb491e7873b9b3f8a77cee6d05f3983280007961"
    sha256 cellar: :any, monterey: "d5f1c59bde721150077ce02180684c837aa35910a981710ba9654c0dcbfc2f53"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "pkg-config" => [:build, :test]
  depends_on "gz-cmake3"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DBUILD_TESTING=OFF"
    cmake_args << "-DCMAKE_INSTALL_RPATH=#{rpath}"

    # Use build folder
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
      cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
      find_package(gz-utils2 QUIET REQUIRED)
      add_executable(test_cmake test.cpp)
      target_link_libraries(test_cmake gz-utils2::gz-utils2)
    EOS
    system "pkg-config", "gz-utils2"
    cflags = `pkg-config --cflags gz-utils2`.split
    ldflags = `pkg-config --libs gz-utils2`.split
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
