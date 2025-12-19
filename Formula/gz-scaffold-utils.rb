class GzScaffoldUtils < Formula
  desc "General purpose classes and functions designed for robotic applications"
  homepage "https://github.com/gazebosim/gz-utils"
  url "https://github.com/gazebosim/gz-utils.git", branch: "main"
  version "4.999.999-0-20251219"
  license "Apache-2.0"

  depends_on "cmake" => [:build, :test]
  depends_on "pkgconf" => [:build, :test]
  depends_on "cli11"
  depends_on "gz-scaffold-cmake"
  depends_on "spdlog"

  conflicts_with "gz-jetty-utils", because: "both install gz-utils"

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
